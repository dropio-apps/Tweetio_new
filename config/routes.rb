ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
   map.root :controller => "home",:action=>'index'
   map.email 'email/message/:email', :controller => "email",:action=>'message'
   map.rss_user 'rss/:user', :controller => "rss",:action=>'rssfeed_user'
   map.media_list 'medias/list/:type' , :controller => "medias",:action=>'index'
   map.change_asset_name 'medias/change_asset_name/:encrypt_id',:controller => "medias",:action=>'change_asset_name'
   map.medias_shared 'medias/shared/:id/:content_id', :controller => "medias",:action=>'shared'
   map.medias_user 'medias/:login' , :controller => "medias",:action=>'user_media'
   map.medias 'medias' , :controller => "medias",:action=>'index'
   map.media_show 'medias/show/:id',:controller => "medias",:action=>'show'
   map.media_delete 'medias/delete/:id',:controller => "medias",:action=>'destroy'
   map.media_file_upload 'add/media',:controller => "home",:action=>'file_upload'
   map.comment_delete 'comments/delete/:id',:controller => "comments",:action=>'destroy'
   map.api_asset 'api/drops/:drop_name/assets/:asset_name/embed_code', :controller=>"home", :action=>"redirect_media"
    map.resources :pictures
    map.connect ':controller/:action/:id'
    map.connect ':controller/:action/:id.:format'
end
