require File.dirname(__FILE__) + '/../test_helper'

class ReleasesControllerTest < ActionController::TestCase
  def test_new_release_form_shown
    get :new
    assert_response :success  
    assert_select "form#new_release" do  
      assert_select "#release_name"
      assert_select "#release_release_date_1i"
    end
  end
  
  def xtest_save_new_form
    post :create, :release=>{:release_date=>'2007-03-11'}
    
  end

end
