Rails.application.routes.draw do
  root 'static_pages#home'
  get 'search', to: 'static_pages#search'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'signin', to: 'sessions#new'
  post 'signin', to: 'sessions#create'
  delete 'logut', to: 'sessions#destroy'
  resources :users, only: [:create, :edit, :update, :destroy]
end
