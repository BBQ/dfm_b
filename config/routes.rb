Dishfm::Application.routes.draw do
  
  resource :oauths do
    get :callback
  end
  match "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  get "logout" => "sessions#destroy", :as => "logout"
  resources :sessions
  
  root :to => "dishfeed#index"
  
  match 'restaurants/:id' => 'restaurants#show', :as => :restaurant
  match 'restaurants' => 'restaurants#index', :as => :restaurants
  
  match 'networks/:id' => 'networks#show', :as => :network
  match 'networks' => 'networks#index', :as => :networks
  match 'networks/:id/:action', :controller => 'networks', :as => :network_details

  match 'dishes/:id' => 'dishes#show', :as => :dish  
  match 'dishes' => 'dishes#index', :as => :dishes
  
  match 'dishfeed' => 'dishfeed#index', :as => :dishfeed
  match 'reviews/:id' => 'reviews#show', :as => :review
  
  match 'likes/add/:id' => 'likes#add', :as => :like
  
  match 'profile' => 'profile#index', :as => :profile
  match ':controller(/:action(/:id(.:format)))'
      
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
