Rails.application.routes.draw do

  resources :editors
  resources :papers do
    member do
      post 'start_review'
      post 'start_meta_review'
      post 'reject'
      post 'withdraw'
    end

    collection do
      get 'recent'
      get 'popular'
      get 'accepted', to: 'papers#popular'
      get 'active'
    end
  end

  get '/papers/lookup/:id', :to => "papers#lookup"
  get '/papers/:id/status.svg', :to => "papers#status", :format => "svg", :as => 'status_badge'
  get '/papers/:doi/status.svg', :to => "papers#status", :format => "svg", :constraints => { :doi => /10.21105\/joss\.\d{5}/}
  get '/papers/:doi', :to => "papers#show", :constraints => {:doi => /.*/}


  get '/dashboard/all', :to => "home#all"
  get '/dashboard/incoming', :to => "home#incoming"
  get '/dashboard', :to => "home#dashboard"
  get '/dashboard/*editor', :to => "home#reviews"

  post '/update_profile', :to => "home#update_profile"
  get '/about', :to => 'home#about', :as => 'about'
  get '/profile', :to => 'home#profile', :as => 'profile'
  get '/auth/:provider/callback', :to => 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout


  # API methods
  post '/papers/api_start_review', :to => 'dispatch#api_start_review'
  post '/papers/api_deposit', :to => 'dispatch#api_deposit'
  post '/dispatch', :to => 'dispatch#github_recevier', :format => 'json'

  root :to => 'home#index'
end
