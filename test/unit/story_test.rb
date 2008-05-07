require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  def test_title_required
    story = Story.new(:title=>'A title')
    assert story.valid?
    story.title = nil
    assert !story.valid?
  end 

  test "stories may be unstarted, in-progress, or done" do
    story = Story.create(:title=>'hello')
    assert_equal 'unstarted', story.status
    assert story.valid?

    story.status = 'in_progress'
    assert story.valid?
    assert_equal 'in_progress', story.status

    story.status = 'done'
    assert story.valid? 
    assert_equal 'done', story.status

    story.status = ''
    assert !story.valid? 

    story.status = 'nearly_done'
    assert !story.valid? 
    assert_equal ["Status can only be unstarted in progress or done"], story.errors.full_messages    

  end

  test "unstarted stories advance to in_progress then to done" do
    story = Story.create(:title=>'abc')
    assert_equal 'unstarted', story.status
    assert story.advance!
    assert_equal 'in_progress', story.status
    assert story.advance!
    assert_equal 'done', story.reload.status   
  end

  test "advancing a done story is a no-op" do
    story = Story.create(:title=>'x', :status=>'done')
    assert !story.advance!
    assert_equal 'done', story.reload.status   
  end    

end
