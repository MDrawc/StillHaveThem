Rails.application.routes.draw do
  root 'static_pages#home'
  get 'search', to: 'static_pages#search'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'signin', to: 'sessions#new'
  post 'signin', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :users, only: [:create, :edit, :update, :destroy]
  resources :collections, except: :index
  resources :games, only: [:create, :destroy]

  delete '/remove/:game_id/:collection_id', to: 'collections#remove_game', as: 'remove'
  delete '/remove_s/:game_id/:collection_id/:id_type', to: 'collections#remove_game_search', as: 'remove_s'
  delete '/move/:game_id/:from_id/:to_id', to: 'collections#move_game', as: 'move'
end
