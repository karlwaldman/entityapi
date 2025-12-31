# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import entities from SAM.gov CSV export"
  task :sam_csv, [:file_path] => :environment do |_t, args|
    file_path = args[:file_path] || ENV["SAM_CSV_FILE"]

    unless file_path && File.exist?(file_path)
      puts "Error: Please provide a valid CSV file path"
      puts "Usage: rake import:sam_csv[/path/to/file.csv]"
      puts "   or: SAM_CSV_FILE=/path/to/file.csv rake import:sam_csv"
      exit 1
    end

    puts "Importing entities from: #{file_path}"
    import_sam_csv(file_path)
  end

  desc "Import Massachusetts SAM.gov entities"
  task ma_entities: :environment do
    file_path = Rails.root.join("data", "ma_entities.csv")
    unless File.exist?(file_path)
      puts "Error: MA entities file not found at #{file_path}"
      exit 1
    end
    import_sam_csv(file_path.to_s)
  end

  desc "Import Rhode Island SAM.gov entities"
  task ri_entities: :environment do
    file_path = Rails.root.join("data", "ri_entities.csv")
    unless File.exist?(file_path)
      puts "Error: RI entities file not found at #{file_path}"
      exit 1
    end
    import_sam_csv(file_path.to_s)
  end

  desc "Import all SAM.gov CSV files from data directory"
  task all_sam: :environment do
    Dir[Rails.root.join("data", "*_entities.csv")].each do |file|
      puts "\n#{'=' * 60}"
      puts "Processing: #{File.basename(file)}"
      puts "=" * 60
      import_sam_csv(file)
    end
  end
end

def import_sam_csv(file_path)
  start_time = Time.current
  imported = 0
  skipped = 0
  errors = []

  # CSV column mapping based on SAM.gov export format
  # "Record Type","Name","Unique Entity ID","CAGE/NCAGE","Congressional District",
  # "City","State/Province","Zip Code","Country","Status","FASCSA Order Flag"

  # Use liberal_parsing to handle malformed CSV (e.g., unescaped quotes in names)
  CSV.foreach(file_path, headers: true, encoding: "UTF-8", liberal_parsing: true) do |row|
    begin
      # Skip header row if present
      next if row["Record Type"] == "Record Type"

      # Extract state from State/Province column
      state = row["State/Province"]&.strip&.upcase
      next if state.blank?

      # Map SAM.gov status to our status enum
      sam_status = row["Status"]&.strip
      status = case sam_status
               when "Active" then "Active"
               when "Expired", "Inactive" then "Inactive"
               when "ID Assigned" then "Active" # New registrations waiting for full activation
               else nil # Skip status validation for unknown statuses
               end

      # Create or find entity
      entity = Entity.find_or_initialize_by(
        source: "sam_gov",
        source_id: row["Unique Entity ID"]&.strip
      )

      # Update entity attributes
      entity.assign_attributes(
        canonical_name: row["Name"]&.strip,
        state: state.length == 2 ? state : nil,
        status: status,
        principal_address: {
          city: row["City"]&.strip,
          state: state,
          zip: row["Zip Code"]&.strip,
          country: row["Country"]&.strip,
          congressional_district: row["Congressional District"]&.strip
        },
        raw_data: row.to_h,
        last_verified_at: Time.current,
        confidence_score: 1.0 # High confidence - direct from SAM.gov
      )

      if entity.save
        # Add identifiers
        if row["Unique Entity ID"].present?
          entity.set_identifier(
            type: "sam_uei",
            value: row["Unique Entity ID"].strip,
            verified: true,
            source: "sam_gov_csv"
          )
        end

        if row["CAGE/NCAGE"].present?
          entity.set_identifier(
            type: "cage",
            value: row["CAGE/NCAGE"].strip,
            verified: true,
            source: "sam_gov_csv"
          )
        end

        imported += 1
        print "." if imported % 100 == 0
      else
        errors << { row: row.to_h, errors: entity.errors.full_messages }
        skipped += 1
      end
    rescue StandardError => e
      errors << { row: row.to_h, error: e.message }
      skipped += 1
    end
  end

  elapsed = Time.current - start_time
  puts "\n\n#{'=' * 60}"
  puts "Import Complete"
  puts "=" * 60
  puts "File: #{File.basename(file_path)}"
  puts "Imported: #{imported}"
  puts "Skipped: #{skipped}"
  puts "Elapsed: #{elapsed.round(2)} seconds"
  puts "Rate: #{(imported / elapsed).round(1)} entities/sec"
  puts "Total entities in database: #{Entity.count}"

  if errors.any?
    puts "\nFirst 5 errors:"
    errors.first(5).each do |err|
      puts "  - #{err}"
    end
  end
end
