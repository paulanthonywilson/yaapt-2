require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  def test_title_required
    story = Story.new(:title=>'A title')
    assert story.valid?
    story.title = nil
    assert !story.valid?
  end
  
end
