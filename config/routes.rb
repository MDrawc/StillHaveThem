Rails.application.routes.draw do
  root 'static_pages#home'
  get 'search', to: 'static_pages#search'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'signin', to: 'sessions#new'
  post 'signin', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users, only: [:create, :edit, :update, :destroy]
  resources :collections, only: [:new, :create, :edit, :update, :destroy]
  resources :games, only: [:create]
end
