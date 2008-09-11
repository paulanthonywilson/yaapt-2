require File.dirname(__FILE__) + '/../test_helper'

HTML_DOCUMENT = HTML::Document
class ReleaseMailerTest < ActionMailer::TestCase
  tests ReleaseMailer

  class << self
    def should_list_story_in_table_for_status(status, story_symbol)
      should "list #{status} items in their own table" do
        %w(estimate body).each do |attribute|
          story = stories(story_symbol)
          assert_select "table##{status} tr#story_#{story.id} td", {:text=>story.send(attribute)},attribute
        end
      end
    end
  end

  def setup
    @release = releases(:tea_and_biscuits)      
    flexmock(@release, :to_burndown_graph=>"my graph")

    @message = ReleaseMailer.create_summary_for(@release)
  end

  context "summary message" do

    should "contain the release description in the subject" do
      assert_match /Tea and biscuits/, @message.subject
    end

    should "be in two parts" do
      assert_equal 2,  @message.parts.size
    end

  end

  context "summary message first part" do
    setup do
      @part = @message.parts[0]
    end

    should "be a jpeg" do
      assert_equal 'image/jpeg', @part.content_type
    end

    should "be base64 encoded" do
      assert_equal 'base64', @part.encoding
    end

    should "have filename ending in png" do
      assert_equal "'burndown.jpg'", @part.disposition_param('filename')
    end

    should "be inline" do
      assert_equal "inline", @part.disposition
    end
  end




  context "summary message second part" do
    setup do
      @part = @message.parts[1]
    end

    should "be html" do
      assert_equal 'text/html', @part.content_type
    end

    should "have release title and name " do
      assert_select '#release_name', 'Tea and biscuits' 
      assert_select '#release_date', '31 May 2008'
    end  

    should "include amount left to do" do
      assert_select '#todo', :text=>3 
    end
    should "include amount done" do
      assert_select '#done', :text=>2
    end
    should_list_story_in_table_for_status('done', :biscuits)
    should_list_story_in_table_for_status('in_progress', :make_coffee)
    should_list_story_in_table_for_status('unstarted', :make_tea)


  end

  def response_from_page_or_rjs
    HTML_DOCUMENT.new(@part.body.strip).root
  end



end
