Rails.application.routes.draw do
  get 'guide', to: 'pages#guide', as: 'guide'
  get 'thanks', to: 'pages#thanks', as: 'thanks'
  get 'contact', to: 'pages#contact', as: 'contact'
  get 'privacy', to: 'pages#privacy', as: 'privacy'
  get 'legal', to: 'pages#legal', as: 'legal'

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

  resources :forms, path: '/', except: :index do
    resources :submissions, only: [:index, :show, :destroy]
  end

  post 'f/:form_uid', to: 'submissions#create', as: 'submissions'

  constraints SignedInConstraint.new do
    resources :forms, path: '/', only: :index
  end

  root to: 'pages#home'
  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
