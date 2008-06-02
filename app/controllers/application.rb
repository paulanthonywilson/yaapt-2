# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :load_releases
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '7a429d5f8135f588c3db12facb4d7e2f'
  
private  
  def load_releases
    @todo_releases = Release.todo
    @done_releases = Release.done
  end
  
end
