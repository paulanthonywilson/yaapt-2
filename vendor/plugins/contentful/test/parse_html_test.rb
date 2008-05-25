require File.join(File.dirname(__FILE__), 'prelude')

class ParseHtmlTest < Test::Unit::TestCase

  def test_empty_tag_pair
    # This is broken in Rails 1.2 - Contentful monkey patches HTML::Document to fix it.
    assert_equal_when_parsed '<tag></tag>', '<tag></tag>'
  end

  def test_tags_are_case_insensitive
    assert_equal_when_parsed '<tagcase />', '<TagCase />'
  end

  def test_attribute_names_are_case_insensitive
    assert_equal_when_parsed '<tag attributecase="x" />', '<tag AttributeCase="x" />'
  end

  def test_text_is_case_sensitive
    assert_not_equal_when_parsed 'abCde', 'abcde'
  end

  def test_attribute_value_is_case_sensitive
    assert_not_equal_when_parsed '<tag attribute="abCde" />', '<tag attribute="abcde" />'
  end

  def test_attribute_order_is_ignored
    assert_equal_when_parsed '<sort this="this" that="that" />', '<sort that="that" this="this" />'
  end

  def test_attribute_quoting_style_is_ignored
    assert_equal_when_parsed "<quote single='ok' none=ok />", '<quote single="ok" none="ok" />'
  end

  def test_whitespace_inside_tags_is_ignored
    assert_equal_when_parsed "<tag \t tabs=ok \n newlines=ok   spaces=ok  />",
      '<tag tabs=ok newlines=ok spaces=ok/>'
  end
  
  def test_whitespace_in_text_is_not_ignored
    assert_not_equal_when_parsed '<tag>some text</tag>', '<tag> some text</tag>'
    assert_not_equal_when_parsed '<tag>some text</tag>', '<tag>some  text</tag>'
    assert_not_equal_when_parsed '<tag>some text</tag>', '<tag>some text </tag>'
  end

  def test_whitespace_in_attribute_value_is_not_ignored
    assert_not_equal_when_parsed '<tag a="some text" />', '<tag a=" some text" />'
    assert_not_equal_when_parsed '<tag a="some text" />', '<tag a="some  text" />'
    assert_not_equal_when_parsed '<tag a="some text" />', '<tag a="some text " />'
  end

  private
  def assert_equal_when_parsed(lhs, rhs)
    assert_equal HTML::Document.new(lhs).root.to_s, HTML::Document.new(rhs).root.to_s
  end

  def assert_not_equal_when_parsed(lhs, rhs)
    assert_not_equal HTML::Document.new(lhs).root.to_s, HTML::Document.new(rhs).root.to_s
  end

end
