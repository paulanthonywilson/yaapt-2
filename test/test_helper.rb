ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all  

  def self.test(name, &body) 
    define_method("test #{name}", body)
  end
end  

class ActionController::TestCase

  def assert_link(link)
    assert_select "a[href='#{link}']"    
  end   

  def assert_redirect_with_flash (redirect_to, flash)
    assert_response :redirect
    assert_redirected_to redirect_to
    follow_redirect
    assert_select '#flash_notice', :text=>flash       
  end

  class << self
    define_method "test_blah" do
      def test_cont
        assert_equal "stories", self.class.name
      end

    end

    def a_new_form_is_displayed_with_fields(model_name, fields)
      define_method "test a new form is displayed with" do
        get :new
        assert_response :success
        assert_select '#errorExplanation', :count=>0
      end

    end

    def a_new_form_should_be_displayed_with(&block)

      define_method "test_a_new_form_is_displayed" do
        get :new
        assert_response :success  
        instance_eval(&block)
      end

      def there_should_be_no_errors_for(method, *args)
        define_method "test no errors for '#{method}' with '#{args.inspect}'" do
          send method, args
          assert_select '#errorExplanation', :count=>0
        end
      end

    end
  end

end
