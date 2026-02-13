Rails.application.routes.draw do
  devise_for :users

  # Публичные страницы
  get "pages/home"
  get "pages/about"
  resources :subscriptions, only: :create

  # Страницы просмотра
  get "timeline", to: "memories#timeline"
  get "family_web", to: "memories#family_web"
  get "family_tree", to: "family_tree#index"
  get "family_tree/:id", to: "family_tree#show", as: :family_tree_member

  get "profile", to: "profile#my", as: "my_profile"
  get "profile/edit", to: "profile#edit", as: "edit_profile"
  patch "profile/update", to: "profile#update", as: "update_profile"

  resources :profile, only: [ :show ]

  # CRUD для родственников
  resources :family_members

  # CRUD для воспоминаний
  resources :memories do
    collection do
      get "my"
      get "by_tag/:tag", to: "by_tag", as: "by_tag"
    end
  end

  # Комментарии
  resources :comments, only: [ :show, :create, :edit, :update, :destroy ]

  # Админская часть
  namespace :admin do
    # Страницы просмотра
    get "timeline", to: "memories#timeline"
    get "family_web", to: "memories#family_web"
    get "family_tree", to: "family_tree#index"
    get "family_tree/:id", to: "family_tree#show", as: :admin_family_tree_member

    # CRUD для родственников
    resources :family_members

    # CRUD для воспоминаний
    resources :memories do
      resources :comments
    end

    # Подписки
    resources :subscriptions
  end

  # API
  namespace :api, format: "json" do
    namespace :v1 do
      resources :subscriptions
      get "welcome/index"
      get "welcome/preview"

      devise_scope :user do
        post "sign_up",          to: "registrations#create"
        post "sign_in",          to: "sessions#create"
        get  "authorize_by_jwt", to: "sessions#authorize_by_jwt"
        get  "sign_out",         to: "sessions#destroy"
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Главная
  # Defines the root path route ("/")
  root "pages#home"
end
