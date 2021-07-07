Rails.application.routes.draw do

  resources :editors
  resources :invitations, only: [:index] do
    put 'expire', on: :member
  end
  resources :papers do
    resources :votes, only: [:create]
    resources :notes, only: [:create, :destroy]

    member do
      post 'start_review'
      post 'start_meta_review'
      post 'reject'
      post 'withdraw'
    end

    collection do
      get 'recent'
      get 'published', to: 'papers#popular'
      get 'active'
      get 'filter', to: 'papers#filter'
      get 'search', to: 'papers#search'
    end
  end

  resources :onboardings, only: [:index, :create, :destroy] do
    member do
      post :resend_invitation
    end
    collection do
      get :pending
      get 'editor/:token', action: :editor, as: :editor
      post :add_editor
      post :accept_editor
      post :invite_to_editors_team
    end
  end

  get '/aeic/', to: "aeic_dashboard#index", as: "aeic_dashboard"
  get '/editors/lookup/:login', to: "editors#lookup"
  get '/papers/lookup/:id', to: "papers#lookup"
  get '/papers/in/:language', to: "papers#filter", as: 'papers_by_language'
  get '/papers/by/:author', to: "papers#filter", as: 'papers_by_author'
  get '/papers/edited_by/:editor', to: "papers#filter", as: 'papers_by_editor'
  get '/papers/reviewed_by/:reviewer', to: "papers#filter", as: 'papers_by_reviewer'
  get '/papers/tagged/:tag', to: "papers#filter", as: 'papers_by_tag'
  get '/papers/issue/:issue', to: "papers#filter", as: 'papers_by_issue'
  get '/papers/volume/:volume', to: "papers#filter", as: 'papers_by_volume'
  get '/papers/year/:year', to: "papers#filter", as: 'papers_by_year'
  get '/papers/:id/status.svg', to: "papers#status", format: "svg", as: 'status_badge'
  get '/papers/:doi/status.svg', to: "papers#status", format: "svg", constraints: { doi: /10.21105\/joss\.\d{5}/}
  get '/papers/:doi', to: "papers#show", constraints: { doi: /10.21105\/joss\.\d{5}/}
  get '/papers/:doi.:format', to: "papers#show", constraints: { doi: /10.21105\/joss\.\d{5}/}

  get '/editor_profile', to: 'editors#profile', as: 'editor_profile'
  patch '/update_editor_profile', to: 'editors#update_profile', as: 'update_editor_profile'

  get '/dashboard/all', to: "home#all"
  get '/dashboard/incoming', to: "home#incoming"
  get '/dashboard/in_progress', to: "home#in_progress"
  get '/dashboard', to: "home#dashboard"

  get '/dashboard/*editor', to: "home#reviews"
  get '/about', to: 'home#about', as: 'about'

  get '/profile', to: 'home#profile', as: 'profile'
  post '/update_profile', to: "home#update_profile"

  get '/auth/:provider/callback', to: 'sessions#create'
  get "/signout" => "sessions#destroy", as: :signout

  get '/blog' => redirect("http://blog.joss.theoj.org"), as: :blog

  # API methods
  post '/papers/api_editor_invite', to: 'dispatch#api_editor_invite'
  post '/papers/api_start_review', to: 'dispatch#api_start_review'
  post '/papers/api_deposit', to: 'dispatch#api_deposit'
  post '/papers/api_assign_editor', to: 'dispatch#api_assign_editor'
  post '/papers/api_assign_reviewers', to: 'dispatch#api_assign_reviewers'
  post '/papers/api_reject', to: 'dispatch#api_reject'
  post '/papers/api_withdraw', to: 'dispatch#api_withdraw'
  post '/dispatch', to: 'dispatch#github_receiver', format: 'json'

  root to: 'home#index'
end
