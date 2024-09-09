Rails.application.routes.draw do
  get 'pages/about'
  # Defines the root path route ("/")
  root "posts#index"

  get 'login', to:'sessions#new'
  post 'login', to:'sessions#create'
  delete 'logout', to:'sessions#destroy'

  get 'signup', to:'users#new'
  post 'signup', to:'users#create'

  get 'about', to:'pages#about'

  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
    member do
      post 'like'
    end
  end

  resources :users, only: [:new, :create]

  # 管理者
  namespace :admin do
    get 'users/index'
    resources :users, only: [:index]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
