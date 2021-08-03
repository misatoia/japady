Rails.application.routes.draw do

  # toppages
  root to: 'toppages#index'

  # 使い方あってる？？
  get 'privacypolicy', to: 'toppages#privacypolicy'
  get 'about', to: 'toppages#about'
    
  # sessions
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'test_request', to: 'sessions#test_request'
  # Facebook関連
  # Login redirect_uri 用 "/auth/facebook"
  get 'auth/facebook/callback', to: 'sessions#facebook_callback'
  # その他対応要件
#  get 'auth/facebook/deletion', to 'user#facebook_deletion'
#  get 'auth/facebook/deauthorize', to 'user#facebook_deauthorize'

  # LINE へのログイン
#  get 'auth/line', to: 'sessions#line'
  
  get 'dashboard', to: 'toppages#dashboard'  

  # users
  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :create, :edit, :update, :destroy] do
    member do
      get :attended
      get :notes
      get :auth
    end
  end
    
  # notes
  resources :notes, only: [:index, :new, :create, :edit, :update, :destroy]

  # lessons
  resources :lessons, only: [:index, :new, :create, :edit, :update, :destroy]
    
  # relationships -- follow
  resources :relationships, only: [:create, :destroy]

  # favorites
  resources :favorites, only: [:create, :destroy]

  # likes
  resources :likes, only: [:create, :destroy]

  # attendances
  resources :attendances, only: [:create, :destroy]

    
end
