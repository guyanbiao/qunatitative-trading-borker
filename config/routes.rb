Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :order_executions

  resources :settings, only: [:index, :create] do
    collection do
      post :update_percentage
    end
  end

  resources :webhooks, only: [] do
    collection do
      post :alert
    end
  end

  resources :usdt_standard_orders, only: [:index] do
    member do
      post :close_position
    end
  end

  root to: 'order_executions#index'
end