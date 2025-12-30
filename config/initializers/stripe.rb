require "stripe"

# Configure Stripe API key and version
Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
Stripe.api_version = "2023-10-16"

# Basic configuration
Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"],
  secret_key: ENV["STRIPE_SECRET_KEY"],
  signing_secret: ENV["STRIPE_WEBHOOK_SECRET"]
}

# Configure retries
Stripe.max_network_retries = 2

# Disable telemetry
Stripe.enable_telemetry = false

# Enable debug logging in development
if Rails.env.development?
  Stripe.log_level = Stripe::LEVEL_DEBUG
end

# Add request monitoring
ActiveSupport::Notifications.subscribe("request.stripe") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  Rails.logger.debug("[Stripe] #{event.payload[:method].upcase} #{event.payload[:path]} - #{event.duration}ms")
end
