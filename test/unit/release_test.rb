require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < ActiveSupport::TestCase

  should_have_many :stories
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
  

end
