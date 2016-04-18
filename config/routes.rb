Rails.application.routes.draw do
  get 'thanks', to: 'pages#thanks', as: 'thanks'

  resources :sessions, only: :create
  resources :users, only: :create
  resources :passwords, only: [:create, :new, :edit, :update], param: :password_reset_token

  get 'sign-in', to: 'sessions#new', as: 'sign_in'
  get 'sign-up', to: 'users#new', as: 'sign_up'
  delete 'sign-out', to: 'sessions#destroy', as: 'sign_out'

  resource :account, controller: :users, only: [:edit, :update] do
    resource :subscription, only: [:show, :new, :create, :update ]
    resources :cards, only: [:index, :new, :create, :destroy ]
    resources :charges, only: :index
  end

  resources :forms, path: '/' do
    resources :submissions, only: [:index, :show, :destroy]
  end

  post 'f/:form_uid', to: 'submissions#create', as: 'submissions'

  root to: 'forms#index'
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
