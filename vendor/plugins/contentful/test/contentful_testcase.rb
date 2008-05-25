require File.join(File.dirname(__FILE__), 'prelude')

original_verbosity = $VERBOSE
$VERBOSE = nil
module Contentful
  BASE_DIRECTORY = File.expand_path(File.join(File.dirname(__FILE__), 'base'))
end
CONTENTFUL_AUTO = false
$VERBOSE = original_verbosity

ActionController::Routing::Routes.draw  {|map| map.connect ":controller/:action/:id" }

class ViewFixtureController < ActionController::Base
end

class ContentfulTestCase < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @controller = ViewFixtureController.new
    set_controller_view_root(File.dirname(__FILE__))
    FileUtils.mkdir_p(view_fixture_directory)
    setup_temporary_base_directory
    @expected_add_contentful_generation = nil
    @tag_node = HTML::Document.new('<tag />').root
  end

  def setup_temporary_base_directory
    @base_directory = Contentful::BASE_DIRECTORY
    FileUtils.mkdir_p(@base_directory)
    assert FileTest.exists?(@base_directory)
  end

  def view_fixture_directory
    File.join(get_controller_view_root, 'view_fixture')
  end

  def setup_view_fixture(template_name, content)
    template_path = File.join(view_fixture_directory, "#{template_name}.rhtml")
    File.open(template_path, 'w') { |view| view.write(content) }
  end

  def subdirectory
    method_name.sub(/^test_/, '')
  end

  def setup_contentful_fixture(filename, content)
    fixture_directory = File.join(@base_directory, @testcase_directory, subdirectory)
    FileUtils.mkdir_p(fixture_directory);
    fixture_filename = File.join(fixture_directory, filename)
    File.open(fixture_filename, 'w') { |file| file.write(content); }
  end

  def teardown
    FileUtils.rm_rf(view_fixture_directory)
    FileUtils.rm_rf(@base_directory)
  end

  def assert_contentful_passes(label = nil)
    if label.nil?
      assert_passes { assert_contentful }
    else
      assert_passes { assert_contentful(label) }
    end
  end

  def assert_passes(&block)
     assert_nothing_raised(&block)
  end

  def assert_contentful_fails(label = nil)
    if label.nil?
      assert_fails { assert_contentful }
    else
      assert_fails { assert_contentful(label) }
    end
  end

  def assert_fails(&block)
    assert_raise(Test::Unit::AssertionFailedError, &block)
  end

  def assert_output(filename, content)
    filename = File.join(@testcase_directory, subdirectory, filename)
    assert_file_under_base(filename, content)
  end

  def assert_file_under_base(path, content)
    filename = File.join(@base_directory, path)
    if content.nil?
      assert !FileTest.exists?(filename), "#{filename} should not exist"
    else
      assert FileTest.exists?(filename), "#{filename} should exist"
      File.open(filename) { |file| assert_equal content, file.read }
    end
  end

  def add_contentful_generation(path)
    # Fairly trivial testing here - but running whole test suites and
    #  checking their output without messing with the top-level unit
    #  test machinery would be tedious. Removing this method override
    #  will cause this suite to noisily exercise the full wiring.
    assert_match %r{#{@expected_add_contentful_generation}expected.html$}, path
  end

  def default_test(abstract)
  end

  private

  # Compatibility: Rails 2.x uses view_paths, earlier Rails use template_root

  def set_controller_view_root(directory)
    if @controller.respond_to?(:view_paths)
      @controller.view_paths = directory
    else
      @controller.template_root = directory
    end
  end

  def get_controller_view_root
    if @controller.respond_to?(:view_paths)
      @controller.view_paths
    else
      @controller.template_root
    end
  end
end
