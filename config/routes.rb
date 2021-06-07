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

  # Facebook へのログイン
  
  # LINE へのログイン
  
  

  # users
  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :create, :edit, :update, :destroy] do
    member do
      get :followings
      get :followers
      get :likes
      get :attended
      get :notes
    end
  end
    
  # notes
#  resources :notes, only: [:index, :new, :create, :edit, :update, :destroy]

  # lessons
#  resources :lessons, only: [:index, :new, :create, :edit, :update, :destroy]
    
  # relationships -- follow
#  resources :relationships, only: [:create, :destroy]

  # favorites
#  resources :favorites, only: [:create, :destroy]

  # likes
#  resources :likes, only: [:create, :destroy]

  # attendances
#  resources :attendances, only: [:create, :destroy]

    
end
