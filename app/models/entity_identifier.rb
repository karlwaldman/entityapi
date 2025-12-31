# frozen_string_literal: true

class EntityIdentifier < ApplicationRecord
  belongs_to :entity

  # Identifier types
  TYPES = %w[ein lei duns state_id sec_cik sam_uei cage dot_number mc_number].freeze

  validates :identifier_type, presence: true, inclusion: { in: TYPES }
  validates :identifier_value, presence: true
  validates :identifier_type, uniqueness: { scope: :entity_id }

  # Scopes
  scope :verified, -> { where(verified: true) }
  scope :of_type, ->(type) { where(identifier_type: type) }

  # Find entity by any identifier
  def self.find_entity(type:, value:)
    find_by(identifier_type: type, identifier_value: value)&.entity
  end
end
