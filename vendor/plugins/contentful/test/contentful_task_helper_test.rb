require File.join(File.dirname(__FILE__), 'contentful_testcase')
require File.join(File.dirname(__FILE__), '..', 'tasks', 'contentful_task_helper')

module Contentful
  class DiffHelper
    def self.clear_commands_ran
      @@commands_ran = []
    end

    def self.run(prefix)
      @@commands_ran.push(command_line(prefix))
      return 1
    end

    def self.commands_ran
      @@commands_ran
    end
  end

  class TaskHelper
    def self.output(ignored)
    end
  end
end

class ContentfulTaskHelperTest < ContentfulTestCase
  def setup
    super
    Contentful::DiffHelper.clear_commands_ran
    ENV['DIFF'] = nil
  end

  def teardown
    teardown_fake_test_directories
    super
  end

  def test_accept_one_change
    setup_files('foo/bar', 'expected.html', 'changed.html')
    assert_file_under_base 'foo/bar/expected.html', 'Expected'
    assert_file_under_base 'foo/bar/changed.html', 'Changed'
    Contentful::TaskHelper.accept(@base_directory)
    assert_file_under_base 'foo/bar/expected.html', 'Changed'
    assert_file_under_base 'foo/bar/changed.html', nil
  end

  def test_accept_removes_files_to_diff
    setup_files('foo/bar',
      'changed.html', 'expected.to_diff', 'changed.to_diff')
    Contentful::TaskHelper.accept(@base_directory)
    assert_file_under_base 'foo/bar/expected.to_diff', nil
    assert_file_under_base 'foo/bar/changed.to_diff', nil
  end

  def test_accept_ignores_nearby_files
    setup_files('foo/bar', 'changed.html')
    setup_files('foo/bar', 'other.changed.to_diff', 'accidental_bystander')
    Contentful::TaskHelper.accept(@base_directory)
    assert_file_under_base 'foo/bar/other.changed.to_diff', 'Changed'
    assert_file_under_base 'foo/bar/accidental_bystander', 'Expected'
  end

  def test_accept_labelled_change
    setup_files('foo/bar',
      'something.changed.html', 'something.expected.to_diff')
    Contentful::TaskHelper.accept(@base_directory)
    assert_file_under_base 'foo/bar/something.expected.html', 'Changed'
    assert_file_under_base 'foo/bar/something.expected.to_diff', nil
  end

  def test_accept_multiple_changes
    setup_files('foo/bar',
      'ok.expected.html', '1.changed.html', '2.changed.html')
    Contentful::TaskHelper.accept(@base_directory)
    assert_file_under_base 'foo/bar/ok.expected.html', 'Expected'
    assert_file_under_base 'foo/bar/1.expected.html', 'Changed'
    assert_file_under_base 'foo/bar/2.expected.html', 'Changed'
  end

  def test_accept_one_change_when_xml
    setup_files('foo/bar', 'expected.xml', 'changed.xml')
    assert_file_under_base 'foo/bar/expected.xml', 'Expected'
    assert_file_under_base 'foo/bar/changed.xml', 'Changed'
    Contentful::TaskHelper.accept(@base_directory)
    assert_file_under_base 'foo/bar/expected.xml', 'Changed'
    assert_file_under_base 'foo/bar/changed.xml', nil
  end

  def test_diff_of_nothing
    Contentful::TaskHelper.diff(@base_directory)
    assert_diff_commands([])
  end

  def test_diff_of_one_change
    setup_files('foo/bar',
      'changed.html', 'expected.to_diff', 'changed.to_diff')
    Contentful::TaskHelper.diff(@base_directory)
    assert_diff_commands(["diff #@base_directory/foo/bar/*.to_diff"])
  end    

  def test_diff_of_two_changes
    setup_files('foo/bar',
      'changed.html', 'expected.to_diff', 'changed.to_diff')
    setup_files('foo/baz',
      'label.changed.html', 'label.expected.to_diff', 'label.changed.to_diff')
    Contentful::TaskHelper.diff(@base_directory)
    assert_diff_commands([
      "diff #@base_directory/foo/bar/*.to_diff",
      "diff #@base_directory/foo/baz/label.*.to_diff"])
  end    

  def test_diff_when_some_files_to_diff_are_missing
    setup_files('foo/bar', 'changed.html', 'expected.to_diff')
    assert_raise(RuntimeError) { Contentful::TaskHelper.diff(@base_directory) }
  end

  def test_diff_does_not_run_if_any_files_are_missing
    setup_files('foo/bar',
      'changed.html', 'expected.to_diff', 'changed.to_diff')
    setup_file('foo/baz', 'changed.html')
    assert_raise(RuntimeError) { Contentful::TaskHelper.diff(@base_directory) }
    assert_diff_commands([])
  end

  def test_diff_of_one_change_when_xml
    setup_files('foo/bar',
      'changed.xml', 'expected.to_diff', 'changed.to_diff')
    Contentful::TaskHelper.diff(@base_directory)
    assert_diff_commands(["diff #@base_directory/foo/bar/*.to_diff"])
  end    

  def test_find_no_changes_in_empty_directory
    assert_equal({}, Contentful::TaskHelper.find_changed(@base_directory))
  end

  def test_find_no_changes
    setup_file('foo/bar', 'expected.html')
    setup_file('foo/baz', 'garbage')
    assert_equal({}, Contentful::TaskHelper.find_changed(@base_directory))
  end

  def test_find_change_in_base_directory
    setup_file('.', 'changed.html')
    assert_equal({"#@base_directory/" => 'html'},
      Contentful::TaskHelper.find_changed(@base_directory))
  end

  def test_find_change_in_subdirectory
    setup_file('foo/bar', 'changed.html')
    assert_equal({"#@base_directory/foo/bar/" => 'html'},
      Contentful::TaskHelper.find_changed(@base_directory))
  end

  def test_find_change_starting_in_subdirectory
    setup_file('foo/bar', 'changed.html')
    assert_equal({"#@base_directory/foo/bar/" => 'html'},
      Contentful::TaskHelper.find_changed("#@base_directory/foo"))
  end

  def test_do_not_find_changes_outside_starting_directory
    setup_file('foo', 'changed.html')
    setup_file('foo/baz', 'changed.html')
    setup_file('foo/bar', 'no_changes')
    assert_equal({},
      Contentful::TaskHelper.find_changed("#@base_directory/foo/bar"))
  end

  def test_find_changes_when_starting_outside_base
    setup_file('foo', 'changed.html')
    setup_file('../outside_base', 'no_changes')
    assert_equal({"#@base_directory/foo/" => 'html'},
      Contentful::TaskHelper.find_changed("#@base_directory/../outside_base"))
    FileUtils.rm_rf("#@base_directory/../outside_base")
  end

  def test_find_labelled_change
    setup_file('.', 'label.changed.html')
    assert_equal({"#@base_directory/label." => 'html'},
      Contentful::TaskHelper.find_changed(@base_directory))
  end

  def test_find_change_when_xml
    setup_file('.', 'changed.xml')
    assert_equal({"#@base_directory/" => 'xml'},
      Contentful::TaskHelper.find_changed(@base_directory))
  end

  def test_suite_with_no_expectations
    assert_suite(@base_directory)
  end

  def test_suite_with_single_expectation
    setup_test_file('functional', 'SingleTest', 'test_only')
    setup_files('single/only', 'expected.html')
    assert_suite(@base_directory, 'test_only')
  end

  def test_suite_with_single_empty_expectation
    setup_test_file('functional', 'SingleTest', 'test_only')
    setup_files('single/only', nil)
    assert_suite(@base_directory, 'test_only')
  end

  def test_suite_with_two_expectations_in_one_testcase
    setup_test_file('functional', 'DoubleTest', 'test_one', 'test_two')
    setup_files('double/one', nil)
    setup_files('double/two', nil)
    assert_suite(@base_directory, 'test_one', 'test_two')
  end

  def test_suite_with_expectations_in_two_testcases
    setup_test_file('functional', 'FirstTest', 'test_one')
    setup_test_file('functional', 'SecondTest', 'test_two')
    setup_files('first/one', nil)
    setup_files('second/two', nil)
    assert_suite(@base_directory, 'test_one', 'test_two')
  end

  def test_suite_only_uses_functional_and_integration_tests
    setup_test_file('functional', 'FunctionalTest', 'test_one')
    setup_test_file('integration', 'IntegrationTest', 'test_two')
    setup_test_file('unit', 'UnitTest', 'test_three')
    setup_files('functional/one', nil)
    setup_files('integration/two', nil)
    setup_files('unit/three', nil)
    assert_suite(@base_directory, 'test_one', 'test_two')
  end

  def test_suite_needs_test_cases_matching_expectations
    setup_test_file('functional', 'PresentTest', 'test_this')
    setup_files('absent/this', nil)
    assert_suite(@base_directory)
  end

  def test_suite_needs_test_methods_matching_expectations
    setup_test_file('functional', 'PresentTest', 'test_this')
    setup_files('present/that', nil)
    assert_suite(@base_directory)
  end

  def test_suite_starting_in_subdirectory
    setup_test_file('functional', 'FirstTest', 'test_one')
    setup_test_file('functional', 'SecondTest', 'test_two')
    setup_files('first/one', nil)
    setup_files('second/two', nil)
    assert_suite(File.join(@base_directory, 'first'), 'test_one')
  end

  def test_suite_copes_with_namespaced_tests
    setup_file_with_content(File.join('..', 'functional', 'namespace'),
      "namespaced_test.rb", "module Namespace\n" +
        testfile_content('NamespacedTest', 'test_scoped') +
      "end\n")
    setup_files('namespace/namespaced/scoped', nil)
    assert_suite(@base_directory, 'test_scoped')
  end

  private
  def setup_file(subdirectory, file)
    setup_files(subdirectory, file)
  end

  def setup_files(subdirectory, *files)
    files.each do |file|
      setup_file_with_content(subdirectory, file,
        file =~ /changed/ ? 'Changed' : 'Expected')
    end
  end

  def testfile_content(name, *methods)
    content = ""
    content += "class #{name} < Test::Unit::TestCase\n"
    methods.each {|method| content += "  def #{method}\n  end\n"}
    content += "end\n"
    content
  end

  def setup_test_file(subdirectory, name, *methods)
    setup_file_with_content(File.join('..', subdirectory),
      "#{name.underscore}.rb", testfile_content(name, *methods))
  end

  def setup_file_with_content(subdirectory, file, content)
    subdirectory = File.join(@base_directory, subdirectory)
    FileUtils.mkdir_p(subdirectory)
    File.open(File.join(subdirectory, file), 'w') do |created|
      created.write(content)
    end unless file.nil?
  end

  def assert_diff_commands(expected_cmds)
    assert_equal(expected_cmds.sort, Contentful::DiffHelper.commands_ran.sort)
  end

  def assert_suite(start_directory, *test_methods)
    suite = Contentful::TaskHelper.suite(start_directory)
    assert_equal test_methods.sort, suite.tests.map(&:method_name).sort
    assert_equal 'Contentful', suite.name
  end

  def teardown_fake_test_directories
    ['functional', 'integration', 'unit'].each do |subdirectory|
      test_directory = File.join(@base_directory, '..', subdirectory)
      FileUtils.rm_rf(test_directory) if File.exists?(test_directory)
    end
  end
end
