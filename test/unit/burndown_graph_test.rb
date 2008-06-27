require File.dirname(__FILE__) + '/../test_helper'
require 'burndown_graph'


class BurndownGraphTest < Test::Unit::TestCase

  StubReleaseHistory = Struct.new(:date, :left_todo)

  def setup
    @release = releases(:tea_and_biscuits)
    @gruff = flexmock('gruff')
    @gruff.should_ignore_missing
    flexmock(Gruff::AllLabelLine, :new=>@gruff)
    @testee = BurndownGraph.new
  end
  
 

  should "have a title" do
    @testee.title = "hello title"
    @gruff.should_receive(:title=).with("hello title").once
    @testee.to_gruff
  end

  should "graph history dates against estimate totals" do
    @testee.histories=histories(['2009-03-1', 5], ['2009-03-2', 6], ['2009-03-3', 7])
    @testee.release_date = Date::civil(2009,3,3)
    @gruff.should_receive(:data).with("burndown", [5,6,7]).once
    @testee.to_gruff   
  end

  should "fill gaps in history dates with the preceding total" do
    @testee.histories=histories(['2009-03-1', 5],  ['2009-03-3', 7])
    @testee.release_date = Date::civil(2009,3,3)
    @gruff.should_receive(:data).with("burndown", [5,5,7]).once
    @testee.to_gruff   
  end

  should "fill up to the release date with nil totals" do
    @testee.histories=histories(['2009-03-1', 5], ['2009-03-2', 6])
    @testee.release_date = Date::civil(2009,3,4)
    @gruff.should_receive(:data).with("burndown", [5,6,nil,nil]).once
    @testee.to_gruff
  end

  should "only graph up to the release date" do
    @testee.histories=histories(['2009-03-1', 5], ['2009-03-2', 6], ['2009-03-3', 7])
    @testee.release_date = Date::civil(2009,3,2)
    @gruff.should_receive(:data).with("burndown", [5,6]).once
    @testee.to_gruff   
  end  

  should "label at begin, 1/3, 2/3, and end marks" do
    @testee.histories=histories(['2009-03-1', 5])
    @testee.release_date = Date::civil(2009,3,9)
    @gruff.should_receive(:labels=).with(0=>'01 Mar 2009', 3=>'04 Mar 2009', 6=>'07 Mar 2009', 8=>'09 Mar 2009').once
    @testee.to_gruff
  end
  
  should "be ok with just one datapoint" do
    @testee.histories=histories(['2009-03-1', 1])
    @testee.release_date = Date::civil(2009,3,1)
    @testee.to_gruff
  end
  
  should "be ok with no data" do
    @testee.histories=[]
    @testee.release_date = Date::civil(2009,3,1)
    @testee.to_gruff
  end
  
  should "initialise with a block" do
    @gruff.should_receive(:title=).with("hello title").once
    t = 'hello title'
    BurndownGraph.new do |g|
      g.title=t
    end.to_gruff
  end
  
  should "fill to yesterday with latest previous history date" do
    flexmock Date, :today=>Date::civil(2009,3,3)
    @testee.histories=histories(['2009-03-1', 1])
    @testee.release_date = Date::civil(2009,3,4)
    @gruff.should_receive(:data).with("burndown", [1,1,nil,nil]).once
    @testee.to_gruff
  end
  
  should "only graph from start date, if set" do
    @testee.histories=histories(['2009-03-1', 5], ['2009-03-2', 6], ['2009-03-3', 7])
    @testee.start_date = Date::civil(2009,3,2)
    @testee.release_date = Date::civil(2009,3,3)
    @gruff.should_receive(:data).with("burndown", [6,7]).once
    @testee.to_gruff   
    
  end
  
  should "set the minimum value to 0 after setting the histories" do
    @testee.histories=histories(['2009-03-1', 1])
    @testee.release_date = Date::civil(2009,3,1)
    @gruff.should_receive(:data).with("burndown", [1]).ordered.once
    @gruff.should_receive(:minimum_value=).with(0).ordered.once
    @testee.to_gruff
  end
  

private

  def histories(*short_histories)
    short_histories.map{|short_history| StubReleaseHistory.new Date::strptime(short_history[0]), short_history[1]}
  end


end