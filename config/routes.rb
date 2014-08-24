ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # custom

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  ##########
  # public
  
  # user management
  map.login               '/login', :controller => 'user', :action => 'login'
  map.logout              '/logout', :controller => 'user', :action => 'logout'
  map.signup              '/signup', :controller => 'user', :action => 'signup'
  map.profile             '/profile', :controller => 'user', :action => 'profile'
  
  # journal
  map.edit_journal        '/edit/journal/:name', :controller => 'journal', :action => 'edit'
  map.new_journal         '/edit/journal', :controller => 'journal', :action => 'edit'
  map.view_journal        '/view/journal/:name', :controller => 'journal', :action => 'view'
  map.view_journal_page   '/view/journal/:name/page/:page', :controller => 'journal', :action => 'view'

  ##########
  # service
  
  map.pin_journal_page    '/journal/:id/pin/page/:page', :controller => 'journal', :action => 'pin_page'
  map.pin_journal_story   '/journal/:id/pin/story/:story_id/page/:page', :controller => 'journal', :action => 'pin_story'

  ####################
  # begin theme support fix http://agilewebdevelopment.com/plugins/theme_support
  
  #map.connect             '/themes/:theme/images/:filename', :filename => /.*/, :controller => 'theme', :action => 'images'
  #map.connect             '/themes/:theme/stylesheets/:filename', :filename => /.*/, :controller => 'theme', :action => 'stylesheets' 
  #map.connect             '/themes/:theme/javascript/:filename', :filename => /.*/, :controller => 'theme', :action => 'javascript'
  map.connect             '/themes/*whatever', :controller => 'theme', :action => 'error'  

  # end theme support fix
  ####################

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
