require "health-monitor-rails"

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }

  mount HealthMonitor::Engine, at: "/"

  resources :data_sets do
    member do
      get "map"
      get "analyze"
    end
  end

  resources :common_incident_types, only: [] do
    collection do
      get "search"
    end
  end

  resources :classifications
  resources :dashboards, only: [:index, :show]

  root "dashboards#index"
end
