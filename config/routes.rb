Rails.application.routes.draw do
  root 'static_pages#home'
  get 'info', to: 'static_pages#info', as: 'info'
  get 'doc', to: 'static_pages#doc', as: 'doc'

  get 'search', to: 'static_pages#search_page'
  get 'search_games', to: 'search_igdb#search'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'signin', to: 'sessions#new'
  post 'signin', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  delete 'async_logout', to: 'sessions#async_destroy'
  post 'copy_move', to: 'games#copy_move'
  post 'edit', to: 'games#edit'

  resources :collections, except: :index
  resources :games, only: [:new, :create]
  resources :shares, only: [:new, :edit, :create, :update, :destroy]
  resources :platforms, only: [:destroy]

  delete '/rm/', to: 'collections#remove_game', as: 'remove'
  delete '/rm_s/', to: 'collections#remove_game_search', as: 'remove_s'

  get 'edit_form/:game_id/:collection_id/:view', to: 'games#edit_form', as: 'edit_form'
  get 'copy_form/:game_id/:collection_id/:view', to: 'games#copy_form', as: 'copy_form'

  get 'ls/:igdb_id/:hg_id', to: 'games#list_show', as: 'list_show'
  get 'cs/:igdb_id', to: 'games#cover_show', as: 'cover_show'
  get 'ps/:igdb_id/:g_id', to: 'games#panel_show', as: 'panel_show'

  get 'graph_form/:id', to: 'charts#form', as: 'graph_form'
  get 'g_graph_form/:id', to: 'charts#guest_form', as: 'guest_graph_form'

  get 'graphs', to: 'charts#graphs', as: 'graphs'
  get 'g_graphs', to: 'charts#graphs_for_guest', as: 'guest_graphs'

  get 'shared/:token', to: 'shares#shared', as: 'shared'

  delete 'logout_guest', to: 'shares#leave'
  get '/sh_collections/:id/', to: 'collections#show_guest', as: 'show_guest'

  get 'del/:name/:id', to: 'collections#del_form', as: 'del_form'

  get '/settings', to: 'users#settings', as: 'settings'
  post '/change_gpv', to: 'users#change_gpv', as: 'change_gpv'

  delete '/user', to: 'users#destroy'
  patch '/user', to: 'users#update'

  get '/export_a', to: 'exports#export_collections', as: 'export_a'
  get '/export_b', to: 'exports#export_platforms', as: 'export_b'

  post '/change_order', to: 'collections#change_order', as: 'change_order'

  resources :account_activations, only: [:edit]

  post '/ral', to: 'account_activations#resend_activation_link', as: 'resend_activ_link'

  resources :password_resets, only: [:new, :create, :edit, :update]
end
