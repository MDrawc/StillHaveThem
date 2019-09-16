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
  resources :games, only: [:new, :create]

  delete '/rm/:game_id/:collection_id/:view', to: 'collections#remove_game', as: 'remove'
  delete '/rm_s/:game_id/:collection_id', to: 'collections#remove_game_search', as: 'remove_s'

  get 'edit_form/:game_id/:collection_id/:view', to: 'games#edit_form', as: 'edit_form'
  get 'cm_form/:game_id/:collection_id/:view', to: 'games#cm_form', as: 'cm_form'


  get 'l_show/:game_id', to: 'games#list_show', as: 'list_show'
  get 's_l_show/:game_igdb_id', to: 'games#s_list_show', as: 's_list_show'


  get 'c_show/:game_id', to: 'games#cover_show', as: 'cover_show'

  get 'chg_v/:id/:view', to: 'collections#change_view', as: 'change_view'
end
