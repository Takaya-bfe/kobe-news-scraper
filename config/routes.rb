Rails.application.routes.draw do
  root "scraper#index"

  post "/scrape", to: "scraper#scrape"

  get "up" => "rails/health#show", as: :rails_health_check
end
