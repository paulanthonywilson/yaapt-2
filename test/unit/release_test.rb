require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < ActiveSupport::TestCase
  def test_description
    testee = Release.new(:name=>'Arnold', :release_date=>Date::civil(2008,11,03))
    assert_equal "2008-11-03 - Arnold", testee.description
  end
  
  def test_release_date_required
   testee = Release.new(:name=>'Arnold')
   assert !testee.valid? 
  end
end
