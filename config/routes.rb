require "health-monitor-rails"

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }, skip: [:sessions]
  as :user do
    get "login", to: "devise/sessions#new", as: :new_user_session
    post "login", to: "devise/sessions#create", as: :user_session
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session

    get "profile", to: "devise/registrations#edit"
    put "profile", to: "devise/registrations#update"
    patch "profile", to: "devise/registrations#update"
  end

  mount HealthMonitor::Engine, at: "/"

  resources :data_sets, param: :slug do
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

  resources :classifications, only: [:index] do
    collection do
      get "/call_types/data_sets/:data_set_slug/classify",
          to: "classifications/call_types#index",
          as: :classify_data_sets_call_types

      get "/call_types/:slug",
          to: "classifications/call_types#show",
          as: :classify_call_type

      post "/call_types/:slug",
           to: "classifications/call_types#create",
           as: :create_call_types

      get :call_types
    end
  end

  resources :users, param: :slug, only: [:index, :edit, :update, :destroy]
  resources :dashboards, only: [:index, :show]

  root "dashboards#index"
end
