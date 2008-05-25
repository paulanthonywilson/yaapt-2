require 'test/unit'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require File.expand_path(File.dirname(__FILE__)+ '/../../../../config/environment.rb')
Rails::Initializer.run
require 'action_controller/test_process'
