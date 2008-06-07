require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < ActiveSupport::TestCase

  should_have_many :stories
  should_have_many :release_histories

  should_require_attributes :release_date

  def setup
    super
    @all_releases = Release.find(:all)
  end    

  context "release description" do
    setup do
      @testee = Release.new(:name=>'Arnold', :release_date=>Date::civil(2008,11,03))
    end
    should "be composed of name and release date" do
      assert_equal "2008-11-03 - Arnold", @testee.description
    end

    should "be just release date if there is no name" do
      @testee.name = ''
      assert_equal "2008-11-03", @testee.description
    end 
  end

  def self.should_be_ordered_descending_by_release_date 
    should "be ordered descending by release date" do
      assert_equal @found_releases.map(&:release_date).sort.reverse, @found_releases.map(&:release_date)
    end
  end


  context "done" do
    setup do
      @found_releases = Release.done
    end

    should "return all done releases" do
      assert_same_elements @all_releases.select(&:done), @found_releases 
    end

    should_be_ordered_descending_by_release_date
  end

  context "todo" do
    setup do
      @found_releases = Release.todo
    end

    should "return all releases not done" do
      assert_same_elements  @all_releases.reject(&:done), @found_releases 
    end    

    should_be_ordered_descending_by_release_date
  end

  context "estimate_total" do
    should "be total of estimates of stories that are not done" do
      assert_equal 3, releases(:tea_and_biscuits).estimate_total
    end
  end

  context "notify_story_change" do
    setup do
      @release = releases(:tea_and_biscuits)
      @now = Date::civil(2008, 7, 2)
      flexmock(Date, :today=>@today)
    end

    should "populate event history for the day with the estimate total" do
      @release.notify_story_change
      assert_equal 3, @release.release_histories.find_by_history_date(@today).estimate_total
    end

    should "only create one entry per day" do
      @release.release_histories.create(:estimate_total=>5, :history_date=>@today)
      @release.notify_story_change
      today_histories = @release.release_histories.find_all_by_history_date(@today)
      assert_equal 1, today_histories.size
      assert_equal 3, today_histories.first.estimate_total
    end
    
    


  end


end
