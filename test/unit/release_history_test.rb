require File.dirname(__FILE__) + '/../test_helper'

class ReleaseHistoryTest < ActiveSupport::TestCase
  should_have_db_columns :history_date, :left_todo
  should_belong_to :release
  
  
  should "be able to refer to history date as date" do
    history = release_histories(:dinner_party_day_1)
    assert_equal Date::civil(2008,6,3), history.date
    history.date = Date::civil(2008,6,4)
    assert_equal Date::civil(2008,6,4), history.date
    assert history.save
    assert_equal Date::civil(2008,6,4), history.reload.date
    assert_equal history.date, history.date    
  end
end
                            