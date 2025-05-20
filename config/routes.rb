Rails.application.routes.draw do
  post '/sign_in', to: 'auth#sign_in'
  post '/sign_up', to: 'auth#sign_up'
  require 'sidekiq/web'
  require 'sidekiq-scheduler/web'
  # creating commens operations under posts routes
  resources :posts do
    resources :comments
  end

  resources :tags, only: [:index, :show, :new, :create, :destroy, :update]

  root 'posts#index'
  match '*unmatched', to: 'application#route_not_found', via: :all

  if Rails.env.production?
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  else
    mount Sidekiq::Web => '/sidekiq'
  end
  
end
