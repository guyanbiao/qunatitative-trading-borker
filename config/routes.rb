Rails.application.routes.draw do
  namespace :admin do
      resources :users
      resources :alert_logs
      resources :order_executions
      resources :order_execution_logs
      resources :usdt_standard_orders

      root to: "settings#index"
    end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :order_executions

  resources :settings, only: [:index, :create] do
    collection do
      post :update_percentage
    end
  end

  post "webhooks/alert/:token", to: 'webhooks#alert'

  resources :usdt_standard_orders, only: [:index] do
    member do
      post :close_position
    end
  end

  root to: 'order_executions#index'
end