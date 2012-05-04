Dishfm::Application.routes.draw do
  
  get "autocomplete_searches/Index"

  resource :oauths do
    get :callback
  end
  match "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  get "logout" => "sessions#destroy", :as => "logout"
  resources :sessions
  
  root :to => "landing_page#index"
  
  match 'about/terms' => 'static#terms', :as => :terms
  match 'about/privacy' => 'static#privacy', :as => :privacy
  match 'about' => 'static#about', :as => :about
  match 'support' => 'static#support', :as => :support
  
  match 'restaurants/:id' => 'restaurants#show', :as => :restaurant
  match 'restaurants' => 'restaurants#index', :as => :restaurants

  match 'networks/search' => 'networks#index', :as => :network_search  
  match 'networks/:id' => 'networks#show', :as => :network
  match 'networks' => 'networks#index', :as => :networks
  match 'networks/:id/:action', :controller => :networks, :as => :network_details

  match 'dishes/search' => 'dishes#index', :as => :dishes_search
  match 'dishes/:id' => 'dishes#show', :as => :dish  
  match 'dishes' => 'dishes#index', :as => :dishes
  match 'dishes/delete/:id' => 'dishes#delete', :as => :delete_dish
  
  match 'dishfeed' => 'dishfeed#index', :as => :dishfeed
  match 'reviews/:id' => 'reviews#show', :as => :review
  match 'reviews/delete/:id' => 'reviews#delete', :as => :delete_review
  match 'dishfeed/search/:type' => 'reviews#search', :as => :dishfeed_search
  
  match 'likes/add/:id' => 'likes#add', :as => :like
  match 'sessions/check/' => 'sessions#check', :as => :check_user_ajax
  
  match 'autocomplete' => 'autocomplete_searches#index', :as => :autocomplete

  match 'profile' => 'profile#index', :as => :profile
  match ':controller(/:action(/:id(.:format)))'
  
end
