Rails.application.routes.draw do
  get '/signup', to: 'users#new'
  root 'static_pages#home'
  get 'search', to: 'static_pages#search'
end
