ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'flexmock/test_unit'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all  

  def self.test(name, &body) 
    define_method("test #{name}", body)
  end
  
  def assert_include?(includer, includee)
    assert includer.include?(includee), "expecting '#{includer.inspect}' to include '#{includee.inspect}'"
  end 
end  

class ActionController::TestCase

  def assert_link(link)
    assert_select "a[href='#{link}']"    
  end 
   


  class << self
    def assert_contentful_get_for(actions, params) 
      actions.map(&:to_sym).each do |action|
        define_method "test contentful #{action} with #{params.inspect}" do 
          get action, eval(params)
          assert_response :success
          assert_contentful
        end
      end
    end
    
    def should_link_to(link)
      should "link to #{link}" do
        assert_link eval(link.to_s)
      end
    end
    def should_have_text_on_submit_button(text) 
      should "have '#{text}' on submit button" do
        assert_select "input[type='submit'][value='#{text}']"
      end
    end
    
    def should_have_form(form_name)
      should "have form '#{form_name}'" do
         assert_select "form##{form_name}"
      end
      @form_name = form_name
      yield if block_given?
      @form_name = nil
    end
    
    def with_field field
      form_name = @form_name
      should "have field #{field} in form #{form_name}" do
        assert_select "form##{form_name} input[name='#{field}']"
      end
    end
    
    def with_fields *fields
      fields.each {|field| with_field field}
    end
    
  end
end
