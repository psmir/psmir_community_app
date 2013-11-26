Community::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :messages

  devise_for :users

  resources :users do
    member do
      post 'follow'
      post 'unfollow'
    end

    resources :articles, :only => [:index, :show]
  end

  resources :profiles, :except => [:index, :new, :create, :destroy]

  resources :articles, :except => [:show] do
    resources :comments
  end

  match '/about' => 'pages#about'
  match '/profile/:id/avatar' => 'profiles#avatar', :as => :avatar

  root :to => 'articles#index'


end
