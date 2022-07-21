Rails.application.routes.draw do
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
  resources :dashboards

  root "dashboards#index"
end
