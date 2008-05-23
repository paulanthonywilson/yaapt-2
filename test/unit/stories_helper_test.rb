require File.dirname(__FILE__) + '/../test_helper'
require 'flexmock/test_unit'

class StoriesHelperTest < ActiveSupport::TestCase  
  include StoriesHelper
  
  def test_story_status
    story = Story.new(:id=>25, :status=>'unstarted')
    assert_equal "<span class='h'd(unstarted)'>h'd(unstarted)</span>", story_status(story)
  end
  
  def test_advance_button
    story = Story.new(:id=>25, :status=>'unstarted')
    assert advance_button(story)[:link_to_remote]
  end
  
  def test_advance_button_not_shown_for_done_stories
    story = Story.new(:id=>25, :status=>'done')
    assert_equal '', advance_button(story)
  end
  
  def test_submit_text
    story = flexmock(Story.new)
    assert_equal 'Add story', submit_text(story)
    story.should_receive(:new_record?).and_return(false)
    assert_equal 'Update story', submit_text(story)
  end
  
  def h(escape_me)
    "h'd(#{escape_me})"
  end
  
  def method_missing(method, *args)
    {method=>args}
  end
  
end