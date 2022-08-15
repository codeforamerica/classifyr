require "health-monitor-rails"

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations" }, skip: [:sessions, :registrations]
  as :user do
    get "login", to: "devise/sessions#new", as: :new_user_session
    post "login", to: "devise/sessions#create", as: :user_session
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session

    get "sign_up", to: "devise/registrations#new", as: :new_user_registration
    post "sign_up", to: "devise/registrations#create", as: :user_registration

    get "profile", to: "devise/registrations#edit"
    put "profile", to: "devise/registrations#update"
    patch "profile", to: "devise/registrations#update"
  end

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

  resources :classifications, only: [:index] do
    collection do
      get "/call_types/data_sets/:data_set_id/classify",
          to: "classifications/call_types#index",
          as: :classify_data_sets_call_types

      post "/call_types/data_sets/:data_set_id/classify",
           to: "classifications/call_types#create",
           as: :data_sets_call_types

      get :call_types
    end
  end

  resources :users, only: [:index, :edit, :update, :destroy]
  resources :dashboards, only: [:index, :show]

  root "dashboards#index"
end
