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
    resource :profile, :only => [:show]
  end

  resource :profile, :only => [:show, :edit, :update]

  match '/about' => 'pages#about'
  match '/profile/:id/avatar' => 'profiles#avatar', :as => :avatar

  root :to => 'articles#index'


end
