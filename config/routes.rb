Rails.application.routes.draw do

  devise_for :users
  devise_for :managers
  
  root 'products#index'
  get  'render_article' => 'ajax#render_article'
  post  'add_to_cart' => 'ajax#add_to_cart'

      #新版智付寶
  post "pay2go_return"   => 'orders#pay2go_return'
  post "pay2go_notify"   => 'orders#pay2go_notify'
  post "pay2go_customer" => 'orders#pay2go_customer'

  
      #新版智付通
  post "spgateway_return"   => 'orders#spgateway_return'
  post "spgateway_notify"   => 'orders#spgateway_notify'
  post "spgateway_customer" => 'orders#spgateway_customer'

  namespace :manager do
    root to:  'core#index'
    get 'index' => 'core#index'
    get 'set_session' => 'core#set_session'
    get 'clear' => 'core#clear'
    get 'zbc' => "core#zbc"
    resources :products do
      member do
        post :off_shelf
        post :on_shelf
        post :replenish
        post :mark
        post :unmark
      end
    end    
    resources :orders do
      member do
        post :cancel
        post :shipped
        post :refund
        post :return
        post :return_fail
        get  :message_board
        get  :message_of_cancel
        post :create_message        
      end
    end
    resources :articles do
      member do
        post :sticky
        post :sticky_cancel
      end
    end    
    resources :settings
  end 

  resources :products do
    collection do
      get :total_articles
    end  
    member do 
      post :add_to_cart
    end
  end

  resources :categories, only: [:index, :show]

  resources :carts  do 
    collection do 
      get :checkout
      post :refresh
      delete :delete_cart_item
      delete :clean
    end
  end

  resources :orders  do 
    member do 
      post :realtime_return
      post :realtime_notify
      post :non_realtime_customer
      post :non_realtime_notify
      post :pay2go_cc_notify
      post :pay2go_cc_return
      post :pay2go_wa_notify
      post :pay2go_wa_return
      post :pay2go_atm_return
      post :pay2go_atm_notify
    end
  end   

  namespace :account do 
    get 'index' => 'core#index'
    get 'user_info' => 'core#user_info'
    post 'build_user_info' => 'core#build_user_info'
    resources :orders do 
      member do
        post :cancel
        post :request_return
        get  :message_board
        get  :message_of_cancel
        get  :message_of_return
        post :create_message
        get  :payment_info
      end
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
