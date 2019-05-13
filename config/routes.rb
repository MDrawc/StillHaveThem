Rails.application.routes.draw do
  root 'static_pages#home'
  get 'search', to: 'static_pages#search'
  get 'status', to: 'static_pages#status'
  get 'test', to: 'static_pages#test'
end
