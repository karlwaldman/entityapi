# frozen_string_literal: true

require "net/http"
require "json"

namespace :import do
  desc "Import motor carriers from FMCSA Socrata API"
  task :fmcsa_carriers, [:state, :limit] => :environment do |_t, args|
    state = args[:state]&.upcase
    limit = (args[:limit] || 50000).to_i

    puts "=" * 60
    puts "FMCSA Carrier Import"
    puts "=" * 60
    puts "State filter: #{state || 'ALL'}"
    puts "Limit: #{limit}"
    puts "=" * 60

    FmcsaCarrierImporter.new(state: state, limit: limit).import
  end

  desc "Import FMCSA carriers for top 10 states"
  task fmcsa_top_states: :environment do
    # Top 10 states by search volume (from bootstrap plan)
    states = %w[CA TX NY IL OH FL GA MA PA NJ]

    states.each do |state|
      puts "\n" + "=" * 60
      puts "Importing #{state} carriers..."
      puts "=" * 60
      FmcsaCarrierImporter.new(state: state, limit: 100_000).import
    end
  end

  desc "Import all FMCSA carriers (no state filter)"
  task fmcsa_all: :environment do
    FmcsaCarrierImporter.new(state: nil, limit: 1_000_000).import
  end
end

class FmcsaCarrierImporter
  # Socrata Open Data API endpoint
  # Dataset: Company Census File
  # https://data.transportation.gov/resource/az4n-8mr2.json
  SOCRATA_URL = "https://data.transportation.gov/resource/az4n-8mr2.json"

  # Fields we want to retrieve (based on actual schema)
  SELECT_FIELDS = %w[
    dot_number
    legal_name
    dba_name
    carrier_operation
    hm_ind
    phy_street
    phy_city
    phy_state
    phy_zip
    phy_country
    carrier_mailing_street
    carrier_mailing_city
    carrier_mailing_state
    carrier_mailing_zip
    carrier_mailing_country
    phone
    email_address
    business_org_desc
    status_code
    mcs150_date
    power_units
    total_drivers
    classdef
  ].join(",")

  def initialize(state: nil, limit: 50_000)
    @state = state
    @limit = limit
  end

  def import
    start_time = Time.current
    imported = 0
    skipped = 0
    offset = 0
    batch_size = 1000 # Socrata default limit

    loop do
      records = fetch_batch(offset, batch_size)
      break if records.empty?

      records.each do |record|
        result = import_carrier(record)
        if result
          imported += 1
        else
          skipped += 1
        end

        print "." if (imported + skipped) % 100 == 0
      end

      offset += records.size
      puts " [#{imported} imported, #{skipped} skipped, offset: #{offset}]"

      break if offset >= @limit
      break if records.size < batch_size # Last page

      # Be nice to the API
      sleep(0.5)
    end

    elapsed = Time.current - start_time
    puts "\n" + "=" * 60
    puts "Import Complete"
    puts "=" * 60
    puts "State: #{@state || 'ALL'}"
    puts "Imported: #{imported}"
    puts "Skipped: #{skipped}"
    puts "Elapsed: #{elapsed.round(2)} seconds"
    puts "Rate: #{(imported / elapsed).round(1)} entities/sec" if elapsed > 0
    puts "Total entities in database: #{Entity.count}"
  end

  private

  def fetch_batch(offset, limit)
    uri = URI(SOCRATA_URL)
    params = {
      "$select" => SELECT_FIELDS,
      "$limit" => limit,
      "$offset" => offset,
      "$order" => "dot_number"
    }

    # Add state filter if specified
    if @state.present?
      params["$where"] = "phy_state = '#{@state}'"
    end

    uri.query = URI.encode_www_form(params)

    response = Net::HTTP.get_response(uri)

    if response.code == "200"
      JSON.parse(response.body)
    else
      puts "API Error: #{response.code} - #{response.body}"
      []
    end
  rescue StandardError => e
    puts "Fetch error: #{e.message}"
    []
  end

  def import_carrier(record)
    dot_number = record["dot_number"]
    return false if dot_number.blank?

    # Find or initialize by DOT number (using identifiers)
    existing = EntityIdentifier.find_by(
      identifier_type: "dot_number",
      identifier_value: dot_number
    )

    entity = existing&.entity || Entity.new

    # Map operating status (status_code: A=Active, I=Inactive, N=Not Authorized)
    status = case record["status_code"]
             when "A" then "Active"
             when "I", "N" then "Inactive"
             else nil # Skip validation for unknown
             end

    # Map entity type from business_org_desc
    entity_type = case record["business_org_desc"]
                  when /LLC/i then "LLC"
                  when /CORPORATION/i, /INC/i then "Corporation"
                  when /PARTNERSHIP/i then "Partnership"
                  when /SOLE/i, /INDIVIDUAL/i then "Sole_Proprietorship"
                  else nil # Skip validation for unknown
                  end

    # Build primary name (prefer legal name, fallback to DBA)
    primary_name = record["legal_name"].presence || record["dba_name"]
    return false if primary_name.blank?

    entity.assign_attributes(
      source: "fmcsa",
      source_id: dot_number,
      canonical_name: primary_name,
      legal_name: record["legal_name"],
      entity_type: entity_type,
      status: status,
      state: record["phy_state"]&.strip,
      principal_address: {
        street: record["phy_street"],
        city: record["phy_city"],
        state: record["phy_state"],
        zip: record["phy_zip"],
        country: record["phy_country"]
      },
      mailing_address: {
        street: record["carrier_mailing_street"],
        city: record["carrier_mailing_city"],
        state: record["carrier_mailing_state"],
        zip: record["carrier_mailing_zip"],
        country: record["carrier_mailing_country"]
      },
      raw_data: record,
      last_verified_at: Time.current,
      confidence_score: 0.95 # High confidence - from official FMCSA data
    )

    if entity.save
      # Add DOT number identifier
      entity.set_identifier(
        type: "dot_number",
        value: dot_number,
        verified: true,
        source: "fmcsa_socrata"
      )

      true
    else
      false
    end
  rescue StandardError => e
    puts "Import error for DOT #{dot_number}: #{e.message}"
    false
  end
end
