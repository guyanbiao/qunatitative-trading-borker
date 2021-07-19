Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'

  authenticate :trader do
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :admin do
      resources :alert_logs
      resources :usdt_standard_orders

      root to: "usdt_standard_orders#index"
    end
  devise_for :traders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :order_executions
  resources :users do
    member do
      get :new_order
      post :disable
      post :enable
    end
  end

  resources :settings, only: [:index, :create] do
    collection do
      post :update_percentage
    end
  end

  resources :batch_executions

  post "webhooks/alert/:token", to: 'webhooks#alert'



  resources :usdt_standard_orders, only: [:index] do
    collection do
      post :close_position
    end
  end

  get 'weixin/callback', to: 'weixin#callback'
  get 'weixin/redirect', to: 'weixin#redirect'

  get 'health', to: 'health#check'
  root to: 'home#index'
end