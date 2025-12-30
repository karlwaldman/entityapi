# EntityAPI

Developer-first API for business entity lookup and verification.

## Overview

EntityAPI aggregates fragmented government registry data into a single, affordable, self-service platform. Search US business entities across 50 state registries, federal databases (SAM.gov, GLEIF), and international sources.

## Features

- **Entity Search**: Fuzzy name matching with confidence scores
- **Bulk Validation**: Upload CSV for batch verification
- **Multi-Source**: SAM.gov, GLEIF, state Secretary of State registries
- **Real-time Updates**: Fresh data from authoritative sources

## Quick Start

```bash
# Clone and setup
git clone https://github.com/karlwaldman/entityapi.git
cd entityapi
bundle install

# Configure database
cp .env.example .env
bundle exec rails db:create db:migrate

# Start server
bundle exec rails server
```

## API Endpoints

```
GET  /v1/entities/search    # Search entities by name
GET  /v1/entities/:id       # Get entity details
POST /v1/entities/match     # Find best match for partial data
POST /v1/entities/bulk      # Batch validation
```

## Data Sources

| Source | Coverage | API |
|--------|----------|-----|
| SAM.gov | Federal contractors | Official API |
| GLEIF | LEI entities | Official API |
| State SOS | 50 states | Scraping |

## Tech Stack

- Ruby on Rails 7.2 (API-only)
- PostgreSQL with pg_trgm for fuzzy search
- Sidekiq for background jobs
- Redis for caching

## License

Proprietary - All rights reserved.
