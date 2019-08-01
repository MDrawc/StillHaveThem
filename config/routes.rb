Rails.application.routes.draw do
  root 'static_pages#home'
  get 'search', to: 'static_pages#search_page'
  get 'search_games', to: 'static_pages#search'
  get 'about', to: 'static_pages#about'
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'
  get 'settings', to: 'static_pages#settings'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'signin', to: 'sessions#new'
  post 'signin', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  post 'copy_move', to: 'games#copy_move'
  post 'edit', to: 'games#edit'

  resources :users, only: [:create, :edit, :update, :destroy]
  resources :collections, except: :index
  resources :games, only: [:create]

  delete '/remove/:game_id/:collection_id', to: 'collections#remove_game', as: 'remove'
  delete '/remove_s/:game_id/:collection_id/:id_type', to: 'collections#remove_game_search', as: 'remove_s'
end
