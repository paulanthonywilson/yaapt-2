require 'constants'
require 'patch_test_case_run'
require 'assertion_helper'

class Test::Unit::TestCase
  include Contentful::AssertionHelper
end

