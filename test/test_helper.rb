ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all

end  

class ActionController::TestCase
  def assert_link(link)
    assert_select "a[href='#{link}']"    
  end   
  
  def assert_redirect_with_flash (redirect_to, flash)
    assert_response :redirect
    assert_redirected_to redirect_to
    follow_redirect
    assert_select '#flash_notice', :text=>flash       
  end
end
