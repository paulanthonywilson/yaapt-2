require File.dirname(__FILE__) + '/../test_helper'

class ReleaseHistoryTest < ActiveSupport::TestCase
  should_have_db_columns :history_date, :estimate_total
  should_belong_to :release
end
                            