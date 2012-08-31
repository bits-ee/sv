SpanishVillage::Application.routes.draw do

  match '/auth/failure'                                           => 'authentications#failure'        , :as => 'auth_failure'

  scope "(:locale)", :locale => /ru|en|es/ do

    resources :projects
    resources :comments
    resources :contests, :only => [:show]

    resources :users do
      collection do
        get 'login', 'forgot_password', 'reset_password'
        post 'login', 'forgot_password', 'reset_password'
      end
    end

    #resources :pages
    match 'main', :to => 'pages#main'
    match 'what', :to => 'pages#what'
    match 'who',  :to => 'pages#who'
    match 'where',:to => 'pages#where'
    match 'how',  :to => 'pages#how'
    match 'disclaimer',  :to => 'pages#disclaimer'

    match 'dashboard',                                            :to => 'pages#dashboard'

    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id(.:format)))'
    match '/auth/:provider/callback'                                => 'authentications#create'         , :as => 'auth_callback'
    match '/auth/:provider'                                         => 'authentications#index'          , :as => 'auth'
    match '/logout'                                                 => 'authentications#destroy'
    match 'users/:id/(:year)/(:month)/(:day)/',                 :to => 'users#show',                    :via => :get, :as => 'year_month_day_user'
    match 'signup',                                             :to => 'users#new',                     :via => :get, :as => 'signup'
    match 'forgot_password',                                    :to => 'users#forgot_password',         :via => :get, :as => 'forgot_password'
    match 'reset_password',                                     :to => 'users#reset_password',          :via => :get, :as => 'reset_password'
    match 'user_toggle/:id/:status',                            :to => 'users#toggle',                  :via => :get, :as => 'toggle_user'
    match 'project_toggle/:id/:status',                         :to => 'projects#toggle',               :via => :get, :as => 'toggle_project'

    match 'season2011/(:record)',                               :to => 'pages#season2011',              :via => :get, :as => 'season2011'
    #match 'ru', :to => redirect('/')

    match '/:locale' => 'pages#main'
    root :to => 'pages#main'
  end


end


    #resources :authentications do
    #  collection do
    #    #get 'signin'
    #    #get 'signout'
    #  end
    #end

    # You can have the root of your site routed with "root"
    # just remember to delete public/_index.html.

    #  get '/(:locale)/products/(:category)/(page/:page).:extension',
    #    :to => 'products#index',
    #    :as => :products,
    #    :constraints => {
    #      :locale => /[a-z]{2}/,
    #      :category => /.+?/,
    #      :page => /\d+/
    #    },
    #    :defaults => {
    #      :page => 1,
    #      :extension => 'html',
    #      :locale => 'en'
    #    }

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
