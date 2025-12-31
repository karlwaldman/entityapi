# frozen_string_literal: true

require "net/http"
require "json"

namespace :import do
  desc "Import entities from SAM.gov API by state"
  task :sam_api, [:state, :limit] => :environment do |_t, args|
    state = args[:state]&.upcase
    limit = (args[:limit] || 1000).to_i

    unless state.present?
      puts "Error: State is required"
      puts "Usage: rake import:sam_api[CA,1000]"
      exit 1
    end

    puts "=" * 60
    puts "SAM.gov API Import"
    puts "=" * 60
    puts "State: #{state}"
    puts "Limit: #{limit} (API limit: 1,000/day)"
    puts "=" * 60

    SamGovApiImporter.new(state: state, limit: limit).import
  end

  desc "Import SAM.gov entities for top states (respecting daily limit)"
  task sam_api_top_states: :environment do
    # Top states by priority - we can only do ~1000/day total
    states = %w[CA TX NY FL IL]
    per_state = 200 # 1000 / 5 states

    states.each do |state|
      puts "\n" + "=" * 60
      puts "Importing #{state} from SAM.gov API..."
      puts "=" * 60
      SamGovApiImporter.new(state: state, limit: per_state).import
    end
  end
end

class SamGovApiImporter
  # SAM.gov Entity Information API v3
  # Docs: https://open.gsa.gov/api/entity-api/
  SAM_API_URL = "https://api.sam.gov/entity-information/v3/entities"

  # API key from environment or hardcoded for dev
  API_KEY = ENV["SAM_GOV_API_KEY"] || "Z60dZB5G2HaP2u3FLfR7fEXDiRmT9joEZieQoMSt"

  def initialize(state:, limit: 1000)
    @state = state
    @limit = [limit, 1000].min # API has 1000/day limit
  end

  def import
    start_time = Time.current
    imported = 0
    skipped = 0
    page = 0
    page_size = 100

    loop do
      records = fetch_page(page, page_size)
      break if records.nil? || records.empty?

      records.each do |record|
        result = import_entity(record)
        if result
          imported += 1
        else
          skipped += 1
        end

        print "." if (imported + skipped) % 10 == 0
      end

      page += 1
      total_fetched = page * page_size
      puts " [#{imported} imported, #{skipped} skipped, page: #{page}]"

      break if total_fetched >= @limit
      break if records.size < page_size # Last page

      # Respect rate limits
      sleep(0.5)
    end

    elapsed = Time.current - start_time
    puts "\n" + "=" * 60
    puts "Import Complete"
    puts "=" * 60
    puts "State: #{@state}"
    puts "Imported: #{imported}"
    puts "Skipped: #{skipped}"
    puts "Elapsed: #{elapsed.round(2)} seconds"
    puts "Rate: #{(imported / elapsed).round(1)} entities/sec" if elapsed > 0
    puts "Total entities in database: #{Entity.count}"
  end

  private

  def fetch_page(page, size)
    uri = URI(SAM_API_URL)

    params = {
      "api_key" => API_KEY,
      "samRegistered" => "Yes",
      "registrationStatus" => "A", # Active
      "physicalAddressStateCode" => @state,
      "page" => page,
      "size" => size
    }

    uri.query = URI.encode_www_form(params)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 30

    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"

    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      data["entityData"] || []
    else
      puts "API Error: #{response.code} - #{response.body[0..200]}"
      nil
    end
  rescue StandardError => e
    puts "Fetch error: #{e.message}"
    nil
  end

  def import_entity(record)
    # Extract core registration info
    core = record["coreData"] || {}
    entity_info = core["entityInformation"] || {}
    physical_addr = core["physicalAddress"] || {}
    mailing_addr = core["mailingAddress"] || {}

    uei = record["entityRegistration"]&.dig("ueiSAM")
    return false if uei.blank?

    legal_name = entity_info["entityLegalBusinessName"]
    dba_name = entity_info["entityDoingBusinessAsName"]
    primary_name = legal_name.presence || dba_name
    return false if primary_name.blank?

    # Check if entity already exists by UEI
    existing = EntityIdentifier.find_by(
      identifier_type: "sam_uei",
      identifier_value: uei
    )

    entity = existing&.entity || Entity.new

    # Map entity type
    entity_type = case entity_info["entityStructureDesc"]
                  when /LLC/i then "LLC"
                  when /CORPORATION/i, /INC/i then "Corporation"
                  when /PARTNERSHIP/i then "Partnership"
                  when /SOLE/i then "Sole_Proprietorship"
                  when /NONPROFIT/i, /NON-PROFIT/i then "Nonprofit"
                  else nil
                  end

    # Map status
    reg_status = record["entityRegistration"]&.dig("registrationStatus")
    status = reg_status == "A" ? "Active" : "Inactive"

    entity.assign_attributes(
      source: "sam_gov",
      source_id: uei,
      canonical_name: primary_name,
      legal_name: legal_name,
      entity_type: entity_type,
      status: status,
      state: physical_addr["stateOrProvinceCode"],
      principal_address: {
        street: physical_addr["addressLine1"],
        street2: physical_addr["addressLine2"],
        city: physical_addr["city"],
        state: physical_addr["stateOrProvinceCode"],
        zip: physical_addr["zipCode"],
        country: physical_addr["countryCode"]
      },
      mailing_address: {
        street: mailing_addr["addressLine1"],
        street2: mailing_addr["addressLine2"],
        city: mailing_addr["city"],
        state: mailing_addr["stateOrProvinceCode"],
        zip: mailing_addr["zipCode"],
        country: mailing_addr["countryCode"]
      },
      raw_data: record,
      last_verified_at: Time.current,
      confidence_score: 1.0 # Highest confidence - direct from SAM.gov API
    )

    if entity.save
      # Add UEI identifier
      entity.set_identifier(
        type: "sam_uei",
        value: uei,
        verified: true,
        source: "sam_gov_api"
      )

      # Add CAGE code if present
      cage = record["entityRegistration"]&.dig("cageCode")
      if cage.present?
        entity.set_identifier(
          type: "cage",
          value: cage,
          verified: true,
          source: "sam_gov_api"
        )
      end

      # Add DUNS if present (legacy)
      duns = record["entityRegistration"]&.dig("duns")
      if duns.present?
        entity.set_identifier(
          type: "duns",
          value: duns,
          verified: true,
          source: "sam_gov_api"
        )
      end

      true
    else
      false
    end
  rescue StandardError => e
    puts "Import error for UEI #{uei}: #{e.message}"
    false
  end
end
