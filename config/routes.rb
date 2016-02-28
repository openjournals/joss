Rails.application.routes.draw do

  resources :papers do
    member do
      post 'start_review'
      post 'reject'
      get 'status'
    end

    collection do
      get 'recent'
      get 'popular'
      get 'submitted'
    end
  end

  post '/update_profile', :to => "home#update_profile"
  get '/about', :to => 'home#about', :as => 'about'
  get '/profile', :to => 'home#profile', :as => 'profile'
  get '/auth/:provider/callback', :to => 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  root :to => 'home#index'
end
