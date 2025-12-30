source "https://rubygems.org"

ruby "~> 3.2.0"

# Rails
gem "rails", "~> 7.2.3"

# Database
gem "pg", "~> 1.1"

# Web server
gem "puma", ">= 5.0"

# Authentication
gem "bcrypt", "~> 3.1.7"

# JSON serialization
gem "active_model_serializers", "~> 0.10.0"

# CORS handling
gem "rack-cors"

# Rate limiting
gem "rack-attack"

# Background jobs
gem "sidekiq", "~> 7.2"
gem "sidekiq-cron", "~> 1.12"

# HTTP client for scraping
gem "httparty", "~> 0.24.0"
gem "nokogiri", ">= 1.18.9"

# Pagination
gem "kaminari"
gem "api-pagination"

# Stripe billing
gem "stripe", "~> 13.3"

# Error tracking
gem "sentry-ruby"
gem "sentry-rails"

# Email
gem "postmark-rails"

# Caching
gem "bootsnap", require: false

# Windows timezone support
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "dotenv-rails"
  gem "minitest"
  gem "factory_bot_rails"
  gem "faker"
  gem "webmock"
end

group :development do
  gem "listen", ">= 3.5.0"
  gem "annotate"
  gem "rubocop", require: false
end
