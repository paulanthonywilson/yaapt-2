require File.dirname(__FILE__) + '/../test_helper'
require 'flexmock/test_unit'

class ReleasesControllerTest < ActionController::TestCase

  context "sunny day resources" do  
    setup do
      @release = releases(:tea_and_biscuits)
    end

    should_be_restful do |resource|
      resource.create.params = {:name=>"a release", :release_date=>'2007-03-11'}
      resource.update.params = {:name=>'oh something else'}
      resource.actions = [:new, :create, :edit, :update]

      resource.create.redirect = "release_stories_path(@release)"
      resource.update.redirect = "release_stories_path(@release)"
    end
  end

  context "on failing to save" do
    setup do
      @release = flexmock(Release.new, "release", :save=>false, :update_attributes=>false)
      flexmock(Release, :new=>@release, :find=>@release)
    end

    should "redisplay new form" do
      post :create, :release=>{:name=>"a release", :release_date=>'2007-03-11'}
      assert_response :success
      assert_template 'new'
      assert_equal @release, assigns(:release)
    end
    
    should "redisplay edit form" do
      put :update, :id=>@release
      assert_response :success
      assert_template 'edit'
      assert_equal @release, assigns(:release)
    end
    
  end


end
