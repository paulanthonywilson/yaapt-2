require File.join(File.dirname(__FILE__), 'contentful_testcase')

class ContentfulAssetsTest < ContentfulTestCase
  def setup
    super
    @testcase_directory = 'contentful_assets'
  end

  def test_assets_have_dummy_id
    setup_view_fixture :styled, '<%= stylesheet_path("example.css") %>'
    process :styled
    assert_response :ok
    assert_equal 'DUMMY_ASSET_ID', ENV['RAILS_ASSET_ID']
    assert_match /DUMMY_ASSET_ID/, @response.body
  end
end
