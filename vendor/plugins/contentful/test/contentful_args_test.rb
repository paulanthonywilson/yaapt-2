require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ContentfulArgsTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful_args'
  end

  def test_node_argument
    setup_contentful_fixture 'expected.html', '<tag />'
    assert_nothing_raised { assert_contentful @tag_node }
  end

  def test_node_and_label_arguments
    setup_contentful_fixture 'label.expected.html', '<tag />'
    assert_nothing_raised { assert_contentful @tag_node, :label }
  end

  def test_too_many_arguments
    assert_raise(ArgumentError) { assert_contentful :label, 0 }
    assert_raise(ArgumentError) { assert_contentful(@tag_node, :label, 0) }
  end
end
