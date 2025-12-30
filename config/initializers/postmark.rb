# Configure ActionMailer to use Postmark
begin
  # Allow test and staging environments to run without Postmark
  if Rails.env.test? || Rails.env.staging? || ENV["SKIP_POSTMARK"] == "true" || ENV["POSTMARK_API_TOKEN"].blank?
    Rails.logger.warn "Postmark disabled - using test delivery method" if Rails.env.test?
    Rails.logger.warn "Postmark disabled - API token not configured" unless Rails.env.test?
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = false
  else
    # Basic ActionMailer configuration as per Postmark docs
    ActionMailer::Base.delivery_method = :postmark
    ActionMailer::Base.postmark_settings = {
      api_token: ENV["POSTMARK_API_TOKEN"]
    }
  end

  # Set default URL options for mailers
  Rails.application.config.action_mailer.default_url_options = {
    host: ENV["FRONT_URL"] || "localhost:3000",
    protocol: "https"
  }

rescue StandardError => e
  Rails.logger.error "Failed to configure Postmark: #{e.message}"
  Rails.logger.error "Ensure POSTMARK_API_TOKEN is set in your environment"

  # Fallback to test delivery
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = false
end
