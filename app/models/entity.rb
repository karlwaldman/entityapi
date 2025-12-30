# frozen_string_literal: true

class Entity < ApplicationRecord
  has_many :entity_identifiers, dependent: :destroy

  # Validations
  validates :canonical_name, presence: true
  validates :source, presence: true
  validates :source_id, uniqueness: { scope: :source }, allow_nil: true

  # Entity types
  ENTITY_TYPES = %w[
    LLC
    Corporation
    LP
    LLP
    Partnership
    Sole_Proprietorship
    Nonprofit
    Trust
    Other
  ].freeze

  # Statuses
  STATUSES = %w[Active Inactive Dissolved Suspended Merged Converted].freeze

  # US States
  US_STATES = %w[
    AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD
    MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC
    SD TN TX UT VT VA WA WV WI WY DC
  ].freeze

  validates :entity_type, inclusion: { in: ENTITY_TYPES }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  validates :state, inclusion: { in: US_STATES }, allow_nil: true

  # Scopes
  scope :active, -> { where(status: "Active") }
  scope :in_state, ->(state) { where(state: state.upcase) }
  scope :by_type, ->(type) { where(entity_type: type) }
  scope :from_source, ->(source) { where(source: source) }

  # Callbacks
  before_save :normalize_name

  # Search by name using pg_trgm similarity
  scope :search_name, ->(query) {
    normalized = normalize_search_query(query)
    where("normalized_name % ?", normalized)
      .order(Arel.sql("similarity(normalized_name, #{connection.quote(normalized)}) DESC"))
  }

  # Get all identifiers as a hash
  def identifiers
    entity_identifiers.each_with_object({}) do |ident, hash|
      hash[ident.identifier_type] = ident.identifier_value
    end
  end

  # Add or update an identifier
  def set_identifier(type:, value:, verified: false, source: nil)
    ident = entity_identifiers.find_or_initialize_by(identifier_type: type)
    ident.update!(
      identifier_value: value,
      verified: verified,
      source: source || self.source
    )
    ident
  end

  private

  def normalize_name
    self.normalized_name = self.class.normalize_search_query(canonical_name)
  end

  def self.normalize_search_query(query)
    return nil if query.blank?

    query
      .downcase
      .gsub(/[^a-z0-9\s]/, "") # Remove punctuation
      .gsub(/\b(inc|llc|corp|corporation|ltd|limited|co|company)\b/, "") # Remove common suffixes
      .squish
  end
end
