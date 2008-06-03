require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase
  NEW_STORY_PARAMS={ :title=>'A new story', :body=>'as a developer I want this test to pass', :estimate=>1}
  NEW_STORY_PARAMS_WITH_RELEASE=NEW_STORY_PARAMS.merge(:release_id=>Fixtures.identify(:tea_and_biscuits))
  
  
  context "stories with release" do
    setup do
      @story = stories(:make_tea)
    end

    should_be_restful do |resource|
      resource.parent = :release
      resource.create.params = NEW_STORY_PARAMS_WITH_RELEASE
      resource.update.params = { :title=>'Get in hot water' }
      resource.actions.delete :show
      resource.formats = [:html]

      resource.update.redirect  = 'release_stories_path(@story.release)'
      resource.create.redirect =  'release_stories_path(@story.release)'
    end
  end
  
  context "new story  release" do
    setup do
      post :create, :story=>NEW_STORY_PARAMS
    end
    
    should_redirect_to "unassigned_stories_path"
    
  end



  # assert_contentful_get_for %w(index new edit), "{:id=>stories(:make_tea), :release_id=>stories(:make_tea).release}"


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

    should "contain display release details" do
      assert_select ".release"
    end

    should "not have release column" do
      assert_select "td #release_story_#{stories(:make_tea).id}",  :count=>0
    end

    should "link to release edit" do
      assert_link edit_release_path(@release)
    end

  end

  
  context "index without release" do
    setup do
      get :index
    end

    should "list all stories" do
      assert_equal Story.find(:all).size, assigns(:stories).size
    end        

    should "link to new story without release" do
      assert_link new_story_path
    end

    should "not contain display of release details at top" do
      assert_select ".release", :count=>0
    end

    should "have release column for release assigned stories" do
      assert_select "#release_story_#{stories(:make_tea).id}"
    end
  end

  context "index for unassigned stories" do
    
    setup do
      get :unassigned
    end

    should "link to new story without release" do
      assert_link new_story_path
    end

    should "not contain display of release details at top" do
      assert_select ".release", :count=>0
    end

    should "not have release column" do
      assert_select "td #release_story_#{stories(:make_tea).id}",  :count=>0
    end

    should "only list stories for the release" do
      assert_same_elements Story.unassigned, assigns(:stories)
    end
    
  end

  context "index with release" do
    setup do
      get :index
    end

    should "contain advance link for unfinished stories" do
      assert_advance_button_count_for_story 1, :make_tea
    end

    should "not contain advance link for done stories" do
      assert_advance_button_count_for_story 0, :biscuits
    end

  end


  context "advancing a story" do
    should "update status unstarted to in_progress" do
      put :advance, :id=>stories(:make_tea)
      assert_equal 'in_progress', stories(:make_tea).reload.status
      assert_match /update.*in_progress/, @response.body
    end

    should "fail for status done" do
      stories(:make_tea).update_attributes(:status=>'done')
      put :advance, :id=>stories(:make_tea)
      assert_equal 'done', stories(:make_tea).reload.status
      assert_match /alert.*fail/i, @response.body
    end
  end

  context "new story for release" do
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

  private
  def assert_advance_button_count_for_story(expected_count, story)
    assert_select "#story_#{stories(story).id} a img[alt='advance']" , {:count=>expected_count}, "Advance link for story"
  end


end
