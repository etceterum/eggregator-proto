# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require_dependency "login_system"

class ApplicationController < ActionController::Base
  include LoginSystem

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_egg_session_id'

  layout 'main'
  theme 'one'
  
  protected
  
  # hint on handling ActiveRecord::RecordNotFound exception
  # credit goes to http://www.sitepoint.com/blogs/2006/08/30/being-a-good-little-404er/
  def render_404
    respond_to do |format|
      format.html { render :file => "#{RAILS_ROOT}/public/404.html", :status => '404 Not Found' }
      format.xml  { render :nothing => true, :status => '404 Not Found' }
    end
    true
  end

  def rescue_action_in_public(e)
    case e 
    when ActiveRecord::RecordNotFound
      render_404
    else
      super
    end
  end
  
  def rescue_action_locally(e)
    rescue_action_in_public(e)
  end
    
end
