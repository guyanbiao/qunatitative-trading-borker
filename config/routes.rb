Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :order_executions
  resources :settings, only: [:index, :create]
end
