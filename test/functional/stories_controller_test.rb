require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase

  def setup
    super
    @story = stories(:make_tea)
  end



  should_be_restful do |resource|
    resource.create.params = { :title=>'A new story', :body=>'as a developer I want this test to pass', :estimate=>1}
    resource.update.params = { :title=>'Get in hot water' }
    resource.actions.delete :show 
    resource.formats = [:html]

    resource.update.redirect  = 'stories_path'
    resource.create.redirect = 'stories_path'
  end

  assert_contentful_get_for %w(index new edit), "{:id=>stories(:make_tea)}"

  context "advance link on index" do

    setup do
      get :index
    end

    should "be present for unfinished stories" do
      assert_advance_button_count_for_story 1, :make_tea
    end

    should "be absent for done stories" do
      assert_advance_button_count_for_story 0, :biscuits
    end
  end

  def test_advancing_a_story
    put :advance, :id=>stories(:make_tea)
    assert_equal 'in_progress', stories(:make_tea).reload.status
    assert_match /update.*in_progress/, @response.body
  end

  def test_failing_to_advance_a_story
    stories(:make_tea).update_attributes(:status=>'done')
    put :advance, :id=>stories(:make_tea)
    assert_equal 'done', stories(:make_tea).reload.status
    assert_match /alert.*fail/i, @response.body
  end

  def assert_advance_button_count_for_story(expected_count, story)
    assert_select "#story_#{stories(story).id} a img[alt='advance']" , {:count=>expected_count}, "Advance link for story"
  end
end
