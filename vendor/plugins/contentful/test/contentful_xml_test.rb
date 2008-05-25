require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ViewFixtureController
  def xml_content
    render :text => 'content', :content_type => 'text/xml'
  end

  def xml_with_link
    render :text => content_with_link_tag, :content_type => 'text/xml'
  end

  def html_with_link
    render :text => content_with_link_tag
  end

  private
  def content_with_link_tag
    '<rss><channel><link>not allowed in html</link></channel></rss>'
  end
end

class ContentfulXmlTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful_xml'
  end

  def add_contentful_generation(path)
    assert_match %r{#{@expected_add_contentful_generation}expected.xml$}, path
  end

  def test_fail_when_link_tag_used_in_html
    process :html_with_link
    exception = assert_contentful_fails
    assert_match /invalid mark-up in content/i, exception.message
  end

  def test_pass_when_link_tag_used_in_xml
    process :xml_with_link
    assert_contentful_passes
  end

  def test_new_expected_content_uses_xml_suffix
    process :xml_content
    assert_response :ok
    assert_contentful_passes
    assert_output 'expected.html', nil
    assert_output 'expected.xml', 'content'
  end

  def test_changed_content_uses_xml_suffix
    process :xml_content
    setup_contentful_fixture 'expected.xml', 'different content'
    assert_contentful_fails
    assert_output 'changed.html', nil
    assert_output 'changed.xml', 'content'
  end

end
