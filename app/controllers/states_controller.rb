# frozen_string_literal: true

class StatesController < ActionController::Base
  # Enable view rendering for SEO pages (not API-only)
  layout "application"

  # State metadata for SEO
  STATE_DATA = {
    "california" => { abbrev: "CA", name: "California", demonym: "California" },
    "texas" => { abbrev: "TX", name: "Texas", demonym: "Texas" },
    "florida" => { abbrev: "FL", name: "Florida", demonym: "Florida" },
    "new-york" => { abbrev: "NY", name: "New York", demonym: "New York" },
    "illinois" => { abbrev: "IL", name: "Illinois", demonym: "Illinois" },
    "ohio" => { abbrev: "OH", name: "Ohio", demonym: "Ohio" },
    "georgia" => { abbrev: "GA", name: "Georgia", demonym: "Georgia" },
    "massachusetts" => { abbrev: "MA", name: "Massachusetts", demonym: "Massachusetts" },
    "rhode-island" => { abbrev: "RI", name: "Rhode Island", demonym: "Rhode Island" },
    "pennsylvania" => { abbrev: "PA", name: "Pennsylvania", demonym: "Pennsylvania" },
    "new-jersey" => { abbrev: "NJ", name: "New Jersey", demonym: "New Jersey" }
  }.freeze

  before_action :set_state, only: [:show, :search]

  # GET /
  def index
    @states = STATE_DATA.map do |slug, data|
      count = Entity.where(state: data[:abbrev]).count
      data.merge(slug: slug, count: count)
    end.sort_by { |s| -s[:count] }

    @total_entities = Entity.count
  end

  # GET /:state/business-search
  def show
    @entities = Entity.where(state: @state_abbrev)
                      .order(canonical_name: :asc)
                      .limit(50)

    @entity_count = Entity.where(state: @state_abbrev).count
    @by_source = Entity.where(state: @state_abbrev).group(:source).count

    # Top cities in this state
    @top_cities = Entity.where(state: @state_abbrev)
                        .where.not("principal_address->>'city' IS NULL")
                        .group("principal_address->>'city'")
                        .order(Arel.sql("count(*) DESC"))
                        .limit(10)
                        .count
  end

  # GET /:state/business-search?q=query
  def search
    @query = params[:q].to_s.strip
    @entity_count = Entity.where(state: @state_abbrev).count
    @by_source = Entity.where(state: @state_abbrev).group(:source).count

    # Top cities in this state
    @top_cities = Entity.where(state: @state_abbrev)
                        .where.not("principal_address->>'city' IS NULL")
                        .where("principal_address->>'city' != ''")
                        .group("principal_address->>'city'")
                        .order(Arel.sql("count(*) DESC"))
                        .limit(10)
                        .count

    if @query.present?
      @entities = Entity.where(state: @state_abbrev)
                        .search_name(@query)
                        .limit(50)
      @result_count = @entities.count
    else
      @entities = Entity.where(state: @state_abbrev)
                        .order(canonical_name: :asc)
                        .limit(50)
      @result_count = @entity_count
    end

    render :show
  end

  # GET /entity/:id
  def entity
    @entity = Entity.find(params[:id])
    @identifiers = @entity.entity_identifiers.verified
  rescue ActiveRecord::RecordNotFound
    render plain: "Entity not found", status: :not_found
  end

  private

  def set_state
    @state_slug = params[:state]
    @state_data = STATE_DATA[@state_slug]

    unless @state_data
      render plain: "State not found", status: :not_found
      return
    end

    @state_abbrev = @state_data[:abbrev]
    @state_name = @state_data[:name]
  end
end
