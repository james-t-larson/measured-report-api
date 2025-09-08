Rails.application.routes.draw do
  root to: redirect("/api/v1/articles")
  require "sidekiq-scheduler/web"
  mount Sidekiq::Web => "/sidekiq"

  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  # devise_for :users, controllers: {
  #   sessions: "users/sessions",
  #   registrations: "users/registrations"
  #   # Add other controllers as needed
  # }
  #
  # namespace :admin do
  #   namespace :v1 do
  #     resources :articles
  #     resources :categories do
  #       resources :articles, controller: "articles"
  #     end
  #   end
  # end

  namespace :api do
    namespace :v1 do
      # devise_for :users, skip: [ :registrations, :passwords ], controllers: {
      #   sessions: "api/v1/users/sessions"
      # }
      # get "users/me", to: "users/sessions#show"
      resources :articles, only: [ :index, :show ]
      resources :categories, only: [ :index, :show ] do
        resources :articles, only: [ :index ], controller: "articles"
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
