# frozen_string_literal: true

class CreateEntityIdentifiers < ActiveRecord::Migration[7.2]
  def change
    create_table :entity_identifiers, id: :uuid do |t|
      t.references :entity, null: false, foreign_key: true, type: :uuid

      # Identifier details
      t.string :identifier_type, null: false, limit: 50  # ein, lei, duns, state_id
      t.string :identifier_value, null: false, limit: 100
      t.boolean :verified, default: false
      t.string :source, limit: 50  # Where this identifier came from

      t.timestamps
    end

    # Index for lookups by identifier
    add_index :entity_identifiers, [:identifier_type, :identifier_value]
    add_index :entity_identifiers, [:entity_id, :identifier_type], unique: true
  end
end
