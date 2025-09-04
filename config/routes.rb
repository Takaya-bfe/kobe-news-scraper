Rails.application.routes.draw do
  root "scraper#index"

  post "/scrape", to: "scraper#scrape"
end
