require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ContentfulTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful'
  end

  def test_pass_and_create_new_expected_content
    setup_view_fixture :new, "<content />"
    process :new
    assert_response :ok
    @expected_add_contentful_generation = 'pass_and_create_new_expected_content/'
    assert_contentful_passes
    assert_output 'expected.html', '<content />'
  end

  def test_pass_with_identical_content
    setup_view_fixture :contented, 'Contented'
    setup_contentful_fixture 'expected.html', 'Contented'
    process :contented
    assert_contentful_passes
    assert_output 'expected.html', 'Contented'
    assert_output 'changed.html', nil
  end

  def test_pass_removes_older_files
    setup_view_fixture :contented, 'Contented'
    setup_contentful_fixture 'expected.html', 'Contented'
    setup_contentful_fixture 'changed.html', 'Previously discontented'
    setup_contentful_fixture 'expected.to_diff', 'Contented'
    setup_contentful_fixture 'changed.to_diff', 'Previously discontented'
    process :contented
    assert_contentful_passes
    assert_output 'changed.html', nil
    assert_output 'expected.to_diff', nil
    assert_output 'changed.to_diff', nil
  end

  def test_fail_with_differing_content
    setup_contentful_fixture 'expected.html', 'diff'
    assert_contentful_fails
    assert_output 'expected.html', 'diff'
    assert_output 'changed.html', ''
  end

  def test_pass_with_equivalent_html
    setup_view_fixture :equivalent_html, "<TAG b=X A='Y'>cdata<Nested/></Tag>"
    setup_contentful_fixture 'expected.html',
      '<tag a="Y" b="X">cdata<nested /></tag>'
    process :equivalent_html
    assert_contentful_passes
  end

  def test_fail_with_differing_html
    setup_view_fixture :differing_html,
      "<tAg>Gets<normalized Attribute=GetsQuoted /></tag>"
    setup_contentful_fixture 'expected.html',
      '<different> in <many ways="all" /></different>'
    process :differing_html
    assert_contentful_fails
    assert_output 'changed.html',
      '<tag>Gets<normalized attribute="GetsQuoted" /></tag>'
    assert_output 'changed.to_diff', <<CHANGED_TO_DIFF

<tag>
Gets
<normalized attribute="GetsQuoted" />

</tag>
CHANGED_TO_DIFF
    assert_output 'expected.to_diff', <<EXPECTED_TO_DIFF

<different>
 in 
<many ways=\"all\" />

</different>
EXPECTED_TO_DIFF
  end

  def test_attributes_in_files_to_diff
    setup_view_fixture :attributes,
      '<tag zero="0" one="1" two="2" three="3" four="4">text</tag>'
    setup_contentful_fixture 'expected.html',
      '<other four="4" three="3" two="2" one="1" zero="0" />'
    process :attributes
    assert_contentful_fails
    assert_output 'changed.to_diff', <<CHANGED_TO_DIFF

<tag
 four="4"
 one="1"
 three="3"
 two="2"
 zero="0"
>
text
</tag>
CHANGED_TO_DIFF
    assert_output 'expected.to_diff', <<EXPECTED_TO_DIFF

<other
 four="4"
 one="1"
 three="3"
 two="2"
 zero="0"
/>
EXPECTED_TO_DIFF
  end

  def test_fail_with_invalid_html
    setup_view_fixture :invalid_html, "<invalid></html>"
    process :invalid_html
    exception = assert_contentful_fails
    assert_match /invalid mark-up in content/i, exception.message
    assert_output 'expected.html', nil
    assert_output 'changed.html', nil
  end

  def test_error_when_invalid_html_is_expected
    setup_contentful_fixture 'expected.html', '<invalid></html>'
    exception = assert_raise(RuntimeError) { assert_contentful }
    assert_match /invalid mark-up in expected content/i, exception.message
    assert_output 'expected.html', '<invalid></html>'
    assert_output 'changed.html', nil
  end
end
