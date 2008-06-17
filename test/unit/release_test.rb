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
    
    should "consider nil estimate to be zero" do
      releases(:tea_and_biscuits).stories << Story.new
      assert_equal 3, releases(:tea_and_biscuits).estimate_total
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
  
  context "burndown graph" do
    setup do
      @release = releases(:tea_and_biscuits)
      @gruff = flexmock('gruff')
      @gruff.should_ignore_missing
      @gruff.should_receive(:data).with("burndown",on { |data_points| @data_points = data_points} ) 
      @gruff.should_receive(:labels=).with(on { |labels| @labels = labels} ) 
      flexmock(Gruff::AllLabelLine, :new=>@gruff)
    end

    should "have a data item for each day between the earliest history entry and the release date" do
      @release.to_burndown_graph
     assert_equal 31, @data_points.size
    end
    
    should "for days on which there is no release history, carry forward the previous release history value" do
      @release.to_burndown_graph
      assert_equal 25, @data_points[5]
    end
    
    should "fill with nil up to the release history date" do
      @release.to_burndown_graph
      assert_equal nil, @data_points[30]
    end
    
    should "have the estimate total for those days on which there is a release history" do
      @release.to_burndown_graph
      assert_equal 29, @data_points[0]
      assert_equal 15, @data_points[18]
    end
    
    
    should "label the history dates which are first, last, 1/3 and 2/3" do
      @release.to_burndown_graph
      assert_equal({0=>'01 May 2008', 10=>'11 May 2008', 21=>'22 May 2008', 30=>'31 May 2008'}, @labels)
    end

    should "have the release description as its title" do
      @gruff.should_receive(:title=).with(@release.description).once
      @release.to_burndown_graph
    end
    
    
    should "set the minimum value to 0" do
      @gruff.should_receive(:minimum_value=).with(0).once
      @release.to_burndown_graph
    end
    
    should "return the gruff object" do
      assert_equal @gruff, @release.to_burndown_graph
    end
    
    should "do something sensible if there is no data" do
      flexmock(Gruff::Line, :new=>flexmock('gruff expects nothing'))
      releases(:midnight_snack).to_burndown_graph
    end
    
    should "handle one datapoint ok" do
      flexmock(Gruff::AllLabelLine, :new=>flexmock('gruff expects nothing'))
      releases(:midnight_snack).release_histories << 
        ReleaseHistory.create(:history_date=>Date::civil(2008,5,1), :estimate_total=>10);
      releases(:midnight_snack).to_burndown_graph
    end
    
    should "only graph up to the releasedate" do
      @release.release_date = Date::civil(2008, 5, 2)
      @release.to_burndown_graph
      assert_equal 2, @data_points.size
    end
    
    
  end

end
