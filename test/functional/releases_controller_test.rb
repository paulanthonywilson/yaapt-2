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

  context "on failing to save a new story" do
    setup do
      @release = flexmock(Release.new, "release", :save=>false, :id=>5)
      flexmock(Release, :new=>@release)
      post :create, :release=>{:name=>"a release", :release_date=>'2007-03-11'}
    end
    
    should "display the new form" do
      assert_response :success
      assert_template 'new'
      assert_equal @release, assigns(:release)      
    end
  end

  context "on failing to update a story" do
    setup do
      @release = flexmock(Release.new, "release", :save=>false, :update_attributes=>false, :id=>5)
      flexmock(Release)
      Release.should_receive(:find).by_default.and_return([])
      Release.should_receive(:find).with("5").and_return(@release)
      put :update, :id=>@release.id
    end
    
    should "redisplay the edit form" do
      put :update, :id=>@release.id
      assert_response :success
      assert_template 'edit'
      assert_equal @release, assigns(:release)
    end
  end

end
