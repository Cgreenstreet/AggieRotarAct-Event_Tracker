Rails.application.routes.draw do
  root 'events#index'

  # event/switch_view path
  get 'events/view', to: 'events#switch_view'
  # event/attend and event/unattend path
  get 'events/attend', to: 'events#attend'
  get 'events/unattend', to: 'events#unattend'
  resources :events

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :events do
    member do
      get :delete
    end
  end

  # set user path
  get 'users/login', to: 'users#login', as: 'login'
  get 'users/logout', to: 'users#logout', as: 'logout'
  get 'users/form', to: 'users#form', as: 'form'
  post 'users/form', to: 'users#validate_form'
  resources :users

  resources :users do
    member do
      get :delete
    end
  end

  resources :points do
    resources :users
    member do
      get :delete
    end
  end

  # set help path
  get 'help', to: 'help#index'
  get 'help/index'
  get 'help/social_media'
  get 'help/delete_events'
  get 'help/delete_points'
  get 'help/delete_members'
  delete 'help/destroy_events'
  delete 'help/destroy_points'
  delete 'help/destroy_members'
end
