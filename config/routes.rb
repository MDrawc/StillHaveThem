Rails.application.routes.draw do
  root 'static_pages#home'
  get 'search', to: 'static_pages#search'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  resources :users, only: [:create, :edit, :update, :destroy]
end
