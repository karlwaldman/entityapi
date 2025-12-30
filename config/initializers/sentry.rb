Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]

  # Enable performance monitoring
  config.traces_sample_rate = Rails.env.production? ? 0.01 : 1.0

  # Configure breadcrumbs
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Configure environments
  config.enabled_environments = %w[production staging]

  # Add Rails request info
  config.rails.report_rescued_exceptions = true
end

# Add custom tags
Sentry.set_context("tags", {
  environment: Rails.env,
  application: "entityapi"
})
