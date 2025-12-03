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

  # CRUD для родственников
  resources :family_members

  # CRUD для воспоминаний
  resources :memories do
    resources :comments
  end

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
