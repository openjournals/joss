Rails.application.routes.draw do

  resources :papers

  get '/about', :to => 'home#about', :as => 'about'
  get '/auth/:provider/callback', :to => 'sessions#create'
  get "/signout" => "sessions#destroy", :as => :signout

  root :to => 'home#index'
end
