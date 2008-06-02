require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase

  should_require_attributes :title

  should_allow_values_for :status, 'unstarted', 'in_progress', 'done'
  should_not_allow_values_for :status, 'fish', 'nearly_done', '', :message=>/not included/

  context "advancing a story" do
    setup do
      @story = Story.create(:title=>'abc')
    end

    def should_go_from_to(from, to)
      should "go from #{from} to #{to}" do
        @story.status = from
        @story.advance!
        assert_equal to, @story.status
      end
    end

    should_go_from_to('unstarted', 'in_progress')
    should_go_from_to('in_progress', 'done')
  end 

  test "advancing a done story should be a no-op" do
    story = Story.create(:title=>'x', :status=>'done')
    assert !story.advance!
    assert_equal 'done', story.reload.status   
  end  

  test "unassigned stories should not be associated with a release" do
    assert_equal Story.find(:all).reject(&:release_id), Story.unassigned
  end
end
