# frozen_string_literal: true

class CreateEntities < ActiveRecord::Migration[7.2]
  def change
    # Enable required extensions
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_table :entities, id: :uuid do |t|
      # Names
      t.string :canonical_name, null: false, limit: 500
      t.string :legal_name, limit: 500
      t.string :normalized_name, limit: 500  # Lowercase, no punctuation for search

      # Classification
      t.string :entity_type, limit: 50       # LLC, Corporation, LP, LLP, etc.
      t.string :status, limit: 50            # Active, Inactive, Dissolved
      t.string :state, limit: 2              # US state code
      t.string :jurisdiction, limit: 100

      # Dates
      t.date :formation_date
      t.date :dissolution_date

      # Addresses (JSONB for flexibility)
      t.jsonb :registered_agent, default: {}
      t.jsonb :principal_address, default: {}
      t.jsonb :mailing_address, default: {}

      # Source tracking
      t.string :source, null: false, limit: 50       # ca_sos, sam_gov, gleif, etc.
      t.string :source_id, limit: 100                # ID in source system
      t.jsonb :raw_data, default: {}                 # Original response for debugging

      # Quality indicators
      t.decimal :confidence_score, precision: 3, scale: 2
      t.datetime :last_verified_at

      t.timestamps
    end

    # Indexes for common queries
    add_index :entities, :state
    add_index :entities, :status
    add_index :entities, :entity_type
    add_index :entities, :source
    add_index :entities, [:source, :source_id], unique: true
    add_index :entities, :formation_date
    add_index :entities, :last_verified_at

    # Trigram index for fuzzy name search
    add_index :entities, :normalized_name, using: :gin, opclass: :gin_trgm_ops
  end
end
