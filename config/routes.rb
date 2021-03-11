Rails.application.routes.draw do
  root to: 'dids#index'

  resource :login, only: [:create, :destroy] do
    get :new
  end

  get :coverage, to: 'coverage#index'

  resources :available_dids, only: [:index]
  resources :did_reservations, only: [:index, :show, :create, :destroy]

  namespace :dynamic_forms do
    constraints ->(r) { r.xhr? } do
      get 'regions/select', to: 'regions#select'
      get 'cities/select', to: 'cities#select'
    end
  end

  resource  :balance, only: :show
  resources :orders, except: [:edit, :update, :new] do
    new do
      get  :new
      post :new
    end
  end
  resources :dids, except: [:new, :create, :destroy] do
    collection do
      post :batch_action_content, constraints: ->(req) { req.xhr? }
      post :batch_action
    end
  end
  resources :trunks
  resources :trunk_groups
  resources :cdr_exports, except: [:edit, :update, :destroy]
  resources :capacity_pools, only: [:index, :show, :update]
  resources :shared_capacity_groups
  resources :requirements, only: [:index, :show]
  resources :identities
  resources :addresses do
    collection do
      get :search_options, constraints: ->(req) { req.xhr? }
    end
  end
  resources :address_verifications, only: [:index, :show]
  resources :proofs, only: [:create, :destroy]
  resources :callbacks, only: [:index, :create]
end
