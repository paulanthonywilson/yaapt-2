require File.dirname(__FILE__) + '/../test_helper'
require 'burndown_graph'

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

  context "release totals" do
    should "provide total of estimates of stories that are not done in 'total_todo'" do
      assert_equal 3, releases(:tea_and_biscuits).total_todo
    end

    should "consider nil estimate to be zero" do
      releases(:tea_and_biscuits).stories << Story.new
      assert_equal 3, releases(:tea_and_biscuits).total_todo
    end
    
    should "include in_progress in 'total_todo'" do
      releases(:tea_and_biscuits).stories << Story.new(:estimate=>4, :status=>'in_progress')
      assert_equal 7, releases(:tea_and_biscuits).total_todo
    end
    
    should "provide the total estimate in 'total_estimate" do
      assert_equal 5, releases(:tea_and_biscuits).total_estimate
    end

    should "provide the total estimate of stories that are done in 'total_done'" do
      assert_equal 2, releases(:tea_and_biscuits).total_done
    end
  end
  
  

  
  
  

  context "notify_story_change" do
    setup do
      @release = releases(:tea_and_biscuits)
      @today = Date::civil(2008, 7, 2)
      flexmock(Date, :today=>@today)
    end

    should "populate event history for the day with the estimate total" do
      @release.notify_story_change
      assert_equal 3, @release.release_histories.find_by_history_date(@today).total_todo
    end

    should "only create one entry per day" do
      @release.release_histories.create(:total_todo=>5, :history_date=>@today)
      @release.notify_story_change
      today_histories = @release.release_histories.find_all_by_history_date(@today)
      assert_equal 1, today_histories.size
      assert_equal 3, today_histories.first.total_todo
    end
  end

  context "burndown graph" do
    setup do
      @release = releases(:tea_and_biscuits)
      @gruff = flexmock('gruff')
      @gruff.should_receive(:to_blob).with('png').and_return('blobby')
      @gruff.should_ignore_missing
      
      flexmock(Gruff::AllLabelLine).should_receive(:new).with(650).and_return(@gruff)
    end

    should "be an all label line graph" do
      @gruff.should_receive(:title=).with(@release.description).once
      @gruff.should_receive(:data).with("burndown",on { |data_points| data_points.size == 30} ).once 
      assert_equal 'blobby', @release.to_burndown_graph
    end
    
    should "be able to specify the size" do
      flexmock(Gruff::AllLabelLine).should_receive(:new).with(260).and_return(@gruff).once
      @release.to_burndown_graph(260)
    end
    
    should "be able to specify the format" do
      @gruff.should_receive(:to_blob).with('jpeg').and_return('jpegy').once
      #assert_equal 'jpegy',
       @release.to_burndown_graph(650, 'jpeg')
    end
  end

  context "story lists" do
    setup do
      @release = releases(:tea_and_biscuits)
    end
    
    should "have only done stories in done  list" do
      assert_equal([stories(:biscuits)], @release.done_stories)
    end

    should "have only unstarted stories in unstarted  list" do
      assert_equal([stories(:make_tea)], @release.unstarted_stories)
    end

    should "have only in-progress stories in in-progress list" do
      assert_equal([stories(:make_coffee)], @release.in_progress_stories)
    end

  end


end

