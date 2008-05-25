require File.join(File.dirname(__FILE__), 'contentful_testcase')

module Down
  module AndDownAgain
    class ContentfulNamespacedTest < ContentfulTestCase
      def setup
        super
        @testcase_directory = 'down/and_down_again/contentful_namespaced'
      end

      def test_basic_use
        setup_contentful_fixture 'fail.expected.html', 'x'
        assert_contentful_fails :fail
        assert_output 'fail.changed.html', ''
        assert_output 'fail.expected.to_diff', 'x'
        assert_output 'fail.changed.to_diff', ''
        @expected_add_contentful_generation =
          'and_down_again/contentful_namespaced/basic_use/pass.'
        assert_contentful_passes :pass
      end
    end
  end
end
