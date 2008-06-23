require File.dirname(__FILE__) + '/../test_helper'
require 'flexmock/test_unit'

class StoriesHelperTest < ActiveSupport::TestCase  
  include StoriesHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::RecordIdentificationHelper

  def test_story_status
    story = Story.new(:id=>25, :status=>'unstarted')
    assert_equal "<span class='h'd(unstarted)'>h'd(unstarted)</span>", story_status(story)
  end

  def test_advance_button
    story = Story.new(:id=>25, :status=>'unstarted', :release_id=>1)
    assert_match /link_to_remote\(.*advance.*\)/, advance_button(story)
  end

  def test_advance_button_not_shown_for_done_stories
    story = Story.new(:id=>25, :status=>'done')
    assert_equal '', advance_button(story)
  end

  def test_advance_button_not_shown_for_stories_without_release
    story = Story.new(:id=>25, :status=>'unstarted')
    assert_equal '', advance_button(story)
  end


  context "release description cell" do

    setup do
      @story = flexmock(Story.new, :id=>55, :release=>flexmock(:description=>"release description", :id=>111))     
    end

    should "be nil unless release is not nil" do
      assert !release_description_cell(@story, flexmock('story'))
      assert release_description_cell(@story, nil)      
    end

    should "be empty cell if story does not belong to release" do
      assert_equal "<div id='release_story_33'></div>", 
        release_description_cell(flexmock(Story.new, :id=>33, :release=>nil), nil)
    end

    should "be identified as a release cell if story belongs to a release" do
      assert_include? release_description_cell(@story, nil), dom_id(@story, 'release')
    end

    should "link to the release" do
      assert_include? release_description_cell(@story, nil), release_stories_path(@story.release)
    end
    should "describe the release" do
      assert_include? release_description_cell(@story, nil), @story.release.description
    end

  end

  def h(escape_me)
    "h'd(#{escape_me})"
  end

  def advance_story_path(story)
    "advance_story_path(#{story.id})"
  end


  def link_to(name, options={}, htmloptions=nil)
    "link_to(#{name}, #{options.inspect}, #{htmloptions.inspect})"
  end

  def release_stories_path(release)
    "release_stories_path(#{release.id})"
  end

  def link_to_remote(name, options={}, htmloptions=nil)
    "link_to_remote(#{name}, #{options.inspect}, #{htmloptions.inspect})"
  end

  context "title" do
    should "be title if set" do
      @title = "Mavis"
      assert_equal "Mavis", title
    end

    should "be release description if a release is set" do
      @release = flexmock(:description=>'Marvin')
      assert_equal "Marvin", title
    end

    should "be 'Stories' if no title or release set" do
      assert_equal "Stories", title
    end
  end
  
  
end