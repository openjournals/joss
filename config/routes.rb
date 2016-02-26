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

  get '/about', :to => 'home#about', :as => 'about'
  get '/editors', :to => 'home#editors', :as => 'editors'
  get '/auth/:provider/callback', :to => 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  root :to => 'home#index'
end
