Community::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :messages

  devise_for :users

  resources :articles do
    resources :comments
  end

  resources :users do
    member do
      post 'follow'
      post 'unfollow'
    end

    resources :articles, :only => [:index]
  end

  resources :profiles, :except => [:index, :new, :create, :destroy]

  match '/about' => 'pages#about'
  match '/profile/:id/avatar' => 'profiles#avatar', :as => :avatar

  root :to => 'articles#index'


end
