require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase
  NEW_STORY_PARAMS={ :body=>'A new story',  :estimate=>1}
  NEW_STORY_PARAMS_WITH_RELEASE=NEW_STORY_PARAMS.merge(:release_id=>Fixtures::identify(:tea_and_biscuits))
  
  
  context "stories with release" do
    setup do
      @story = stories(:make_tea)
    end

    should_be_restful do |resource|
      resource.parent = :release
      resource.create.params = NEW_STORY_PARAMS_WITH_RELEASE
      resource.update.params = { :body=>'Get in hot water' }
      resource.actions.delete :show
      resource.formats = [:html]

      resource.update.redirect  = 'release_stories_path(@story.release)'
      resource.create.redirect =  'release_stories_path(@story.release)'
    end
  end
  
  context "new story release" do
    setup do
      post :create, :story=>NEW_STORY_PARAMS
    end
    
    should_redirect_to "unassigned_stories_path"
    
  end
  
  
  context "index with release" do
    setup do
      @release = releases(:tea_and_biscuits)
      get :index, :release_id=> @release
    end
  
  
    should "only list stories for the release" do
      assert_equal @release.stories.size, assigns(:stories).size
    end
  
    should "link to new story for release" do
      assert_link new_release_story_path(@release)
    end
  
    should "contain display release description" do
      assert_select "h1", :title=>@release_description
    end
  
    should "not have release column" do
      assert_select "td #release_story_#{stories(:make_tea).id}",  :count=>0
    end
  
    should "have link to release edit" do
      assert_link edit_release_path(@release)
    end
    
    
    should "include a hidden field in new story form for the release id" do
      assert_select "form#new_story input#story_release_id[value='#{@release.id}']"
    end
    
    should_link_to 'burndown_release_path(releases(:tea_and_biscuits))'
  
    should "contain advance link for unfinished stories" do
      assert_advance_button_count_for_story 1, :make_tea
    end
  
    should "not contain advance link for done stories" do
      assert_advance_button_count_for_story 0, :biscuits
    end
  
    should "contain stories in dom id 'story_list'" do
      assert_select "#story_list #story_#{stories(:make_tea).id}"
    end
    
    should_not_assign_to(:listing_all_stories)
    should_not_assign_to(:listing_unassigned_stories)
    should_have_form(:new_story)
    should_have_text_on_submit_button('Add story')
    should "have release_id in add story form" do
      assert_select "form#new_story input#story_release_id[value='#{@release.id}']"
    end
    
  
  end
  
  
  context "index for all stories" do
    setup do
      get :index
    end
  
    should "list all stories" do
      assert_equal Story.find(:all).size, assigns(:stories).size
    end        
  
    should "link to new story without release" do
      assert_link new_story_path
    end
  
  
    should "have release column for release assigned stories" do
      assert_select "#release_story_#{stories(:make_tea).id}"
    end
    
    should "contain stories in dom id 'all_story_list'" do
      assert_select "#all_story_list #story_#{stories(:make_tea).id}"
    end
    should_assign_to(:listing_all_stories)
    should_not_assign_to(:listing_unassigned_stories)
  
    should "not have form for new story" do
       assert_select "form#new_story", :count=>0
     end
  
  end
  
  context "index for unassigned stories" do
    
    setup do
      get :unassigned
    end
    
    should_link_to :new_story_path
  
    should "not contain display of release details at top" do
      assert_select ".release", :count=>0
    end
  
    should "not have release column" do
      assert_select "td #release_story_#{stories(:slaughter_ox).id}",  :count=>0
    end
  
    should "only list stories for the release" do
      assert_same_elements Story.unassigned, assigns(:stories)
    end
    
    should "contain stories in dom id 'story_list'" do
      assert_select "#story_list #story_#{stories(:slaughter_ox).id}"
    end
  
    should_have_form(:new_story)
    should_not_assign_to(:listing_all_stories)
    should_assign_to(:listing_unassigned_stories)
    should_have_text_on_submit_button('Add story')
    
  end
  
  
  
  context "advancing a story" do
    should "update status unstarted to in_progress" do
      put :advance, :id=>stories(:make_tea)
      assert_equal 'in_progress', stories(:make_tea).reload.status
      assert_template 'advance'
    end
  
    should "fail for status done" do
      stories(:make_tea).update_attributes(:status=>'done')
      put :advance, :id=>stories(:make_tea)
      assert_equal 'done', stories(:make_tea).reload.status
      assert_match /alert.*fail/i, @response.body
    end
  end
  
  context "creating story for release" do
    setup do
      @release = releases(:tea_and_biscuits)
      @release_story_count = @release.stories.count
      post :create, {:story=>NEW_STORY_PARAMS_WITH_RELEASE}
    end
  
    should_respond_with :redirect
    should "be added to the release" do
      assert_equal @release_story_count + 1, @release.reload.stories.count
    end 
  end
  
  context "destroying story with release" do
    setup do
      @story=stories(:make_tea)
      delete :destroy, :id=>@story
    end
    should_redirect_to 'release_stories_path(@story.release)'
  end
  context "destroying story without release" do
    setup do
      @story=stories(:slaughter_ox)
      delete :destroy, :id=>@story
    end
    should_redirect_to 'unassigned_stories_path'
  end
  
  
  
  
  
  private
  def assert_advance_button_count_for_story(expected_count, story)
    assert_select "#story_#{stories(story).id} a img[alt='advance']" , {:count=>expected_count}, "Advance link for story"
  end
  
  
  
end
