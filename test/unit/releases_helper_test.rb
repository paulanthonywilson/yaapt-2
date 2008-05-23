require File.dirname(__FILE__) + '/../test_helper'
require 'flexmock/test_unit'

class ReleasesHelperTest < ActiveSupport::TestCase  
  include ReleasesHelper
  
  
  def test_submit_text
    release = flexmock(Release.new)
    assert_equal 'Add release', submit_text(release)
    release.should_receive(:new_record?).and_return(false)
    assert_equal 'Update release', submit_text(release)
  end
  
  
  
end