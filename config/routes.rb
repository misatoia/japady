Rails.application.routes.draw do

  # toppages
  root to: 'toppages#index'

  get 'privacypolicy', to: 'toppages#privacypolicy'
  get 'about', to: 'toppages#about'
    
  # sessions
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Facebook関連
  # Login redirect_uri 用 "/auth/facebook"
  get 'auth/facebook/login', to: 'auth#facebook_login'
  get 'auth/facebook/callback', to: 'auth#facebook_callback'
  # その他対応要件
  post 'auth/facebook/deletion', to: 'auth#facebook_deletion'
  post 'auth/facebook/deauthorize', to: 'auth#facebook_deauthorize'
  get 'auth/facebook/afterdeletion', to: 'auth#facebook_after_deletion'

  # LINE へのログイン
#  get 'auth/line', to: 'auth#line'
  
  get 'dashboard', to: 'toppages#dashboard'

  # users
  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :create, :edit, :update, :destroy] do
    member do
      get :attended
      get :notes
      get :lessons
    end
  end
    
  # notes
  resources :notes, only: [:index, :new, :create, :edit, :update, :destroy]

  # lessons
  resources :lessons, only: [:index, :new, :create, :edit, :update, :destroy]
  get 'coming_lessons', to: 'lessons#coming_lessons'
    
  # relationships -- follow
  resources :relationships, only: [:create, :destroy]

  # favorites
  resources :favorites, only: [:create, :destroy]

  # likes
  resources :likes, only: [:create, :destroy]

  # attendances
  resources :attendances, only: [:create, :destroy]

    
end
