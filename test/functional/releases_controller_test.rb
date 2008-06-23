require File.dirname(__FILE__) + '/../test_helper'

class ReleasesControllerTest < ActionController::TestCase
  class << self
    def should_not_have_edit_release_link
      should "not have edit release link" do
        assert_select "a img[alt='edit']", :count=>0
      end
    end
    
    def should_have_release_form_fields(form_id)
      should_have_form(form_id) {with_fields  'release[release_date]', 'release[name]', 'release[done]', 'release[start_date]'}
    end
  end

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

  context "drop_release" do
    setup do
      @release = releases(:tea_and_biscuits)
      @story = stories(:mix_cocktails)
      @original_story_release = @story.release
      post :drop_release, :id=>@release.id, :story_id=>@story.id
    end

    should "add story to release" do
      assert_equal @release, @story.reload.release
    end

    should "assign previous release" do
      assert_equal @original_story_release, assigns(:previous_release)
    end
  end

  context "drop unassign release" do
    setup do
      @story = stories(:mix_cocktails)
      @original_story_release = @story.release
      post :drop_unassign_release, :story_id=>@story.id
    end

    should "set story's release to null" do
      assert_equal nil, @story.reload.release
    end
    
    should "assign previous release" do
      assert_equal @original_story_release, assigns(:previous_release)
    end
    
    should "assign to story" do
      assert_equal @story, assigns(:story)
    end
  end
  
  context "new relase form" do
    setup do
      get :new
    end
    
   should_have_text_on_submit_button('Add release')
   should_not_have_edit_release_link
   
   should_have_release_form_fields "new_release"
  end
  
  context "update release form" do
     setup do
       get :edit, :id=>releases(:tea_and_biscuits)
     end

    should_have_text_on_submit_button('Update release')
    should_not_have_edit_release_link
    should_have_release_form_fields "edit_release_#{Fixtures.identify(:tea_and_biscuits)}"
  end

end
