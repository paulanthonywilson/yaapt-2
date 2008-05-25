$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'constants'
require 'pathname_relative_to'
require 'diff_helper'
require 'test/unit/testsuite'
require 'active_support/inflector'

module Contentful
  class TaskHelper
    def self.diff(start_directory)
      prefixes_and_formats = find_changed(start_directory)
      prefixes_and_formats.each { |prefix, format| ensure_all_three_files_exist(prefix, format) }
      prefixes_and_formats.each do |prefix, format|
        output '! Diff in ' + changed_relative_to_base(prefix, format)
        Contentful::DiffHelper.run(prefix)
      end
    end

    def self.accept(start_directory)
      find_changed(start_directory).each do |prefix, format|
        output '! Accepting ' + changed_relative_to_base(prefix, format)
        FileUtils.mv("#{prefix}changed.#{format}", "#{prefix}expected.#{format}")
        FileUtils.rm_f("#{prefix}changed.to_diff")
        FileUtils.rm_f("#{prefix}expected.to_diff")
      end
    end

    def self.test(start_directory)
      require 'test/unit/ui/console/testrunner'
      Test::Unit::UI::Console::TestRunner.run(suite(start_directory))
    end

    def self.output(line)
      puts line
    end

    def self.find_changed(start_directory)
      in_directory = based_directory(start_directory)
      output "Finding changes in #{relative_to_app(in_directory)}"
      prefixes_and_formats = {}
      %w(html xml).each do |format|
        Dir.glob("#{in_directory}/**/*changed.#{format}").each do |found|
          prefixes_and_formats[found.chomp("changed.#{format}")] = format
        end
      end
      prefixes_and_formats
    end

    def self.suite(start_directory)
      suite = Test::Unit::TestSuite.new('Contentful')
      content_directories(start_directory).each do |content_directory|
        test_class = File.dirname(content_directory) + '_test'
        test_file_glob = File.join(BASE_DIRECTORY,
          '..', '{functional,integration}', "#{test_class}.rb")
        Dir.glob(test_file_glob).each do |test_file|
          require test_file
          method = 'test_' + File.basename(content_directory)
          catch(:invalid_test) do
            suite << eval("#{Inflector.camelize(test_class)}.new('#{method}')")
          end
        end
      end
      suite
    end

    private
    def self.changed_relative_to_base(prefix, format)
      Pathname.relative_to(BASE_DIRECTORY, "#{prefix}changed.#{format}")
    end

    def self.relative_to_app(subdirectory)
      Pathname.relative_to(RAILS_ROOT, subdirectory)
    end

    def self.based_directory(start_directory)
      if under_base_directory?(start_directory)
        start_directory
      else
        BASE_DIRECTORY
      end
    end

    def self.under_base_directory?(directory)
      path = Pathname.new(directory).realpath.to_s
      base_path = Pathname.new(BASE_DIRECTORY).realpath.to_s
      path[0, base_path.length] == base_path
    end

    def self.ensure_file_exist(file)
      raise RuntimeError.new("Missing #{file}") unless File.exist?(file)
    end

    def self.ensure_all_three_files_exist(prefix, format)
      ensure_file_exist("#{prefix}changed.#{format}")
      ensure_file_exist("#{prefix}expected.to_diff")
      ensure_file_exist("#{prefix}changed.to_diff")
    end

    def self.content_directories(start_directory)
      in_directory = based_directory(start_directory)
      output "Testing expectations in #{relative_to_app(in_directory)}"
      return Dir.glob("#{in_directory}/**/").select do |directory|
        Dir.glob("#{directory}/*/").empty?
      end.map do |leaf_directory|
        Pathname.relative_to(BASE_DIRECTORY, leaf_directory)
      end
    end
  end
end
