Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # SEO State Landing Pages
  root "states#index"
  get "/:state/business-search", to: "states#search", as: :state_search
  get "/entity/:id", to: "states#entity", as: :entity

  # API Docs placeholder
  get "/api", to: proc { [200, { "Content-Type" => "text/html" }, ["<h1>API Documentation Coming Soon</h1>"]] }
end
