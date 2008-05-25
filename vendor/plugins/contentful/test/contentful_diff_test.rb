require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ContentfulDiffTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful_diff'
    @previous_directory = Dir.pwd
    Dir.chdir(File.join(@base_directory, '..'))
  end

  def teardown
    Dir.chdir(@previous_directory)
    super
  end

  def test_default_command
    ENV['DIFF'] = nil
    assert_equal 'diff', Contentful::DiffHelper.command
  end

  def test_overridden_command
    ENV['DIFF'] = 'duff'
    assert_equal 'duff', Contentful::DiffHelper.command
  end

  def test_message_on_fail
    ENV['DIFF'] = 'duff'
    setup_contentful_fixture 'expected.html', 'x'
    assert_match %r(^duff base/contentful_diff/message_on_fail),
      assert_contentful_fails.message
  end
end
