require 'test/unit'
require 'rake'

class RakeTest < Test::Unit::TestCase
  def setup
    super
    @testcase_directory = 'rake'
    @original_directory = Dir.pwd
    setup_rake_as_if_run_from_rails_app_directory
  ensure
    Dir.chdir(@original_directory)
  end

  def teardown
    Dir.chdir(@original_directory)
    super
  end
   
  def test_can_run_contentful_diff_task
    assert_nothing_raised { Rake::Task['contentful:diff'] }
  end

  def test_can_run_contentful_accept_task
    assert_nothing_raised { Rake::Task['contentful:accept'] }
  end

  def test_can_run_contentful_test_task
    assert_nothing_raised { Rake::Task['contentful:test'] }
  end

  def test_contentful_diff_is_contentful_default
    default_task = Rake::Task['contentful']
    assert_equal ['contentful:diff'], default_task.prerequisites
  end

  def test_shortcuts_in_test
    test_accept_task = Rake::Task['test:accept']
    test_diff_task = Rake::Task['test:diff']
    test_content_task = Rake::Task['test:content']
    assert_equal ['contentful:accept'], test_accept_task.prerequisites
    assert_equal ['contentful:diff'], test_diff_task.prerequisites
    assert_equal ['contentful:test'], test_content_task.prerequisites
  end

  def test_pathname_properly_loaded
    # previously didn't get the correct Pathname definition under Windows
    assert Pathname.instance_methods.include?("realpath")
  end

  private
  def setup_rake_as_if_run_from_rails_app_directory
    Dir.chdir(File.dirname(__FILE__) + '/../../../../')
    Rake.application.handle_options
    Rake.application.options.silent = true
    Rake.application.load_rakefile
    assert_nothing_raised { Rake::Task['test:plugins'] }
  end
end
