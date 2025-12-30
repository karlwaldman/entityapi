# EntityAPI Database Bootstrap Strategy

## The Challenge

To deliver value on day one, we need entity data in the database. But scraping all 50 states would take months. We need clever strategies to bootstrap quickly while building data through usage.

## Core Insight: The Validation Flywheel

```
User searches/uploads → We validate → Data enters DB → More coverage → Better SEO → More users
       ↑                                                                              ↓
       └──────────────────────────────────────────────────────────────────────────────┘
```

**Key Principle**: Every user interaction should grow the database.

---

## Strategy 1: Bulk State Data Imports (Immediate)

### Priority States by ROI

| Priority | State | Search Vol | Data Source | Status |
|----------|-------|------------|-------------|--------|
| 1 | **Massachusetts** | 14K | Downloaded | Ready |
| 2 | California | 90.5K | Scrape bizfileonline.sos.ca.gov | High value |
| 3 | Texas | 49.5K | data.texas.gov (Open Data) | Free API |
| 4 | New York | 49.5K | Scrape dos.ny.gov | High value |
| 5 | Florida | 33.1K | Scrape sunbiz.org | Good structure |
| 6 | Illinois | 49.5K | Scrape | |
| 7 | Ohio | 40.5K | Scrape | |
| 8 | Georgia | 33.1K | Scrape | |
| 9 | Washington | - | data.wa.gov (Open Data) | Free |
| 10 | Colorado | - | Bulk download available | Free |

### Open Data First

1. **Texas**: data.texas.gov has business entity data via CKAN API
2. **Washington**: data.wa.gov has corporations data
3. **Colorado**: SOS offers bulk downloads
4. **Delaware**: Important for incorporations, may have bulk data

### Implementation

```ruby
# lib/tasks/import.rake
namespace :import do
  desc "Import Massachusetts entities from CSV"
  task massachusetts: :environment do
    EntityImporter.import_csv("data/ma_entities.csv", source: "ma_sos")
  end

  desc "Import from Texas Open Data API"
  task texas: :environment do
    TexasOpenDataImporter.sync
  end
end
```

---

## Strategy 2: Free Validation Tool (SEO + Data Growth)

### "Verify Your Suppliers" - The Growth Hack

1. **User uploads CSV** of their suppliers (name, state, optional: address, EIN)
2. **Instant check** against our existing database
3. **Queue missing entities** for scraping/validation
4. **Email results in 24 hours** with full validation report
5. **Offer to save as "watchlist"** (signup conversion hook)

### Why This Works

- **Users bring their own data** - they're pre-qualified lists
- **High-intent users** - actively verifying business relationships
- **24-hour SLA gives us time** to scrape missing entities
- **Natural upgrade path** - "Want real-time validation? Upgrade to API"
- **Each upload = database growth**

### Implementation Sketch

```ruby
# app/controllers/api/v1/validation_controller.rb
class Api::V1::ValidationController < ApplicationController
  def create
    upload = ValidationUpload.create!(
      file: params[:file],
      email: params[:email],
      status: :processing
    )

    ValidationWorker.perform_async(upload.id)

    render json: {
      message: "Processing #{upload.row_count} entities",
      estimated_completion: 24.hours.from_now
    }
  end
end
```

### UI Flow

```
Landing Page: "Verify Your Business Partners - Free"
          ↓
[Upload CSV] - Drag & drop, max 500 rows
          ↓
[Enter Email] - For results delivery
          ↓
"Processing... We'll email your results within 24 hours"
          ↓
24 hours later: Email with validation report
          ↓
CTA: "Save your verified list - Create free account"
```

---

## Strategy 3: Federal Data First (High Quality, Free)

### SAM.gov - 600K+ Federal Contractors

- **API**: https://api.sam.gov/entity-information/v3/entities
- **Quality**: Verified data, regularly updated
- **Value**: Real businesses with government contracts
- **Free**: No cost, just need API key

```ruby
# app/services/sam_gov_importer.rb
class SamGovImporter
  SAM_API_URL = "https://api.sam.gov/entity-information/v3/entities"

  def sync_all
    # SAM has ~600K entities
    # Paginate through all results
    page = 0
    loop do
      response = fetch_page(page)
      break if response["entityData"].empty?

      import_batch(response["entityData"])
      page += 1
    end
  end
end
```

### GLEIF - LEI Database

- Global Legal Entity Identifiers
- ~2.4M entities worldwide
- Free API, excellent data quality
- Cross-reference for corporate hierarchies

### SEC EDGAR - Public Companies

- All US public companies
- Officers, directors, beneficial owners
- 10-K, 10-Q filings with entity data
- Free, well-structured

---

## Strategy 4: Search-Driven Scraping (Just-in-Time)

### Concept

Don't pre-scrape everything. Scrape on-demand when users search.

```
User searches "Acme Corp California"
          ↓
Check our DB → Not found
          ↓
Real-time scrape CA SOS
          ↓
Return results + cache in DB
          ↓
Next user gets instant results
```

### Implementation

```ruby
# app/services/entity_search_service.rb
class EntitySearchService
  def search(name:, state:)
    # 1. Check local database
    results = Entity.search(name: name, state: state)
    return results if results.any?

    # 2. Not found - fetch from source
    scraper = StateScraperFactory.for(state)
    scraped = scraper.search(name)

    # 3. Cache results
    scraped.each { |data| Entity.create_from_scrape(data) }

    # 4. Return
    scraped
  end
end
```

### Benefits

- No upfront scraping cost
- Always fresh data (scraped on demand)
- Natural prioritization by user interest
- Builds database organically

### Challenges

- First search is slower (1-5 seconds)
- May hit rate limits on state sites
- Need to handle scraper failures gracefully

---

## Strategy 5: State Page SEO with Real Search

### Every State Page = Real Search Tool

Don't make empty placeholder pages. Each `/[state]/business-search` page:

1. Has a real search form
2. Searches our DB first
3. Falls back to live scrape if needed
4. Shows "last updated" timestamp

### Content Strategy

Each state page includes:
- Working search tool
- "How to verify a business in [State]" guide
- Links to official SOS website
- Entity type breakdown (LLCs vs Corps)
- Recently added entities (proves freshness)

### Example: `/california/business-search`

```
California Business Entity Search
=================================

[Search box: Company name] [Search]

---

Popular Searches Today:
- Apple Inc
- Google LLC
- Meta Platforms, Inc.

---

About California Business Search

The California Secretary of State maintains records of all
business entities registered in California. Use this free
tool to search for LLCs, corporations, and partnerships.

Official source: bizfileonline.sos.ca.gov
```

---

## Strategy 6: Data Partnerships

### Contribute to Open Data Ecosystem

1. **OpenCorporates API**: They have data, we have search volume
2. **State Open Data teams**: Some states want their data used
3. **Academic researchers**: Data exchange partnerships

### Data Licensing

Some states sell bulk data:
- Contact SOS offices directly
- Often $50-500 for complete database
- Worth it for high-value states

---

## Bootstrap Timeline

### Week 1: Foundation
- [ ] Import Massachusetts data (you have it!)
- [ ] Set up SAM.gov API integration
- [ ] Import federal contractors (~600K entities)

### Week 2: Open Data States
- [ ] Texas Open Data API integration
- [ ] Washington state data
- [ ] Colorado bulk import

### Week 3: Top 5 Scrapers
- [ ] California scraper
- [ ] New York scraper
- [ ] Florida scraper

### Week 4: Growth Tools
- [ ] Launch "Verify Your Suppliers" tool
- [ ] State SEO pages with real search
- [ ] Search-driven scraping

### Month 2+
- [ ] Remaining states
- [ ] Entity monitoring
- [ ] International expansion

---

## Data Volume Targets

| Timeframe | Entities | States | Sources |
|-----------|----------|--------|---------|
| Week 1 | 1M | 1 + Federal | MA + SAM.gov |
| Week 2 | 3M | 4 + Federal | +TX, WA, CO |
| Month 1 | 10M | 10 | +CA, NY, FL, IL |
| Month 3 | 25M | 25 | +user searches |
| Month 6 | 50M | 50 | All US + growth |

---

## Key Metrics to Track

1. **Entities added/day** - Database growth rate
2. **Searches resulting in scrape** - Cache miss rate
3. **Validation uploads/week** - Growth tool usage
4. **Entities per state** - Coverage map
5. **Data freshness** - % entities updated in last 30 days

---

## Conclusion

The winning strategy combines:

1. **Bulk imports** for immediate coverage (MA, Federal, Open Data states)
2. **Growth tools** that add data through usage (Validation tool)
3. **Just-in-time scraping** for organic growth
4. **SEO pages** that drive users to search

Every user interaction should make the database better. That's the flywheel.
