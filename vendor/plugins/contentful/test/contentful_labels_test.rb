require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ContentfulLabelsTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful_labels'
  end

  def test_using_label
    setup_contentful_fixture 'name.expected.html', 'diff'
    assert_contentful_fails :name
    assert_output 'name.changed.html', ''
    assert_output 'name.expected.to_diff', 'diff'
    assert_output 'name.changed.to_diff', ''
  end

  def test_multiple_assertions
    setup_view_fixture :first, 'first'
    setup_view_fixture :second, 'second'
    process :first
    @expected_add_contentful_generation = 'multiple_assertions/first.'
    assert_contentful_passes :first
    process :second
    @expected_add_contentful_generation = 'multiple_assertions/second.'
    assert_contentful_passes :second
    assert_output 'first.expected.html', 'first'
    assert_output 'second.expected.html', 'second'
  end

  def test_multiple_assertions_duplicate_labels
    setup_contentful_fixture 'label.expected.html', ''
    assert_contentful_passes :label
    assert_raise_label_error_matching(/duplicate/i) { assert_contentful :label }
  end

  def test_multiple_assertions_missing_both_labels
    setup_contentful_fixture 'expected.html', ''
    assert_contentful_passes
    assert_raise_label_error_matching(/missing/i) { assert_contentful }
  end

  def test_multiple_assertions_missing_label_1
    setup_contentful_fixture 'expected.html', ''
    setup_contentful_fixture 'label.expected.html', ''
    assert_contentful_passes
    assert_raise_label_error_matching(/missing/i) { assert_contentful :label }
  end

  def test_multiple_assertions_missing_label_2
    setup_contentful_fixture 'label.expected.html', ''
    setup_contentful_fixture 'expected.html', ''
    assert_contentful_passes :label
    assert_raise_label_error_matching(/missing/i) { assert_contentful }
  end

  def assert_raise_label_error_matching(pattern, &block)
    error = assert_raise(Contentful::LabelError, &block)
    assert_match pattern, error.message
    assert_match /distinct label/, error.message
  end
end
