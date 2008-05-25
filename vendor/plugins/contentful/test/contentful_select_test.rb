require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ContentfulSelectTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful_select'
    setup_view_fixture :dom,
      '<enclosing><tag id="yes">Text</tag></enclosing><other id="no"/>'
    process :dom
  end

  def test_select_pass
    setup_contentful_fixture '#yes.expected.html', '<tag id="yes">Text</tag>'
    assert_passes { select_contentful "#yes" }
  end

  def test_empty_select_fail
    setup_contentful_fixture 'no_match.expected.html', ''
    assert_fails { select_contentful "no_match" }
  end

  def test_select_fail
    setup_contentful_fixture 'other.expected.html', '<other id="different">'
    assert_fails { select_contentful "other" }
  end

  def test_inner_select
    setup_contentful_fixture 'tag.expected.html', '<tag id="yes">Text</tag>'
    assert_passes { assert_select('enclosing') { select_contentful 'tag' } }
  end

  def test_select_with_label
    setup_contentful_fixture 'label.expected.html', '<tag id="yes">Text</tag>'
    assert_passes { select_contentful 'tag', :label }
  end

  def test_too_many_arguments_to_select
    assert_raise(ArgumentError) { select_contentful 'tag', :label, 0 }
  end
end
