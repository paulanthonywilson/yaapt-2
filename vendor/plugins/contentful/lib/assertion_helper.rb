require 'output_wiring_in_test_result'
require 'pathname_relative_to'
require 'diff_helper'

module Contentful
  class LabelError < RuntimeError
    def message
      super + <<DISTINCT_LABELS

(When using Contentful multiple times in one test method,
 you should supply a distinct label for each use.)
DISTINCT_LABELS
    end
  end

  module AssertionHelper
    def assert_contentful(*args)
      if args[0].is_a?(HTML::Node)
        actual_node = args.shift
      else
        actual_node = parsed_response_body
      end
      label = args.shift
      raise ArgumentError.new(args) unless args.empty?
      register_contentful_label(label)
      register_contentful_format
      FileUtils.mkdir_p(contentful_testmethod_directory) unless File.exists?(contentful_testmethod_directory)
      if FileTest.exists?(contentful_expected_file)
        expected_node = parse_html(File.new(contentful_expected_file).read) {
          |message| RuntimeError.new("Invalid mark-up in expected content:\n#{message}")
        }
        if expected_node == actual_node
          FileUtils.rm_f(contentful_changed_file)
          FileUtils.rm_f(contentful_expected_diffable)
          FileUtils.rm_f(contentful_changed_diffable)
        else
          write_node_file(contentful_changed_file, actual_node)
          write_node_diffable(contentful_expected_diffable, expected_node)
          write_node_diffable(contentful_changed_diffable, actual_node)
          flunk(<<DIFF_INSTRUCTIONS)
#{DiffHelper.command_line(contentful_relative_prefix)}
to see the content change
DIFF_INSTRUCTIONS
        end
      else
        write_node_file(contentful_expected_file, actual_node)
        add_contentful_generation(contentful_expected_file)
      end
    end

    def select_contentful(*args)
      selector = args.shift
      label = args.empty? ? selector.to_sym : args.shift
      raise ArgumentError.new(args) unless args.empty?
      selected_node = HTML::Node.new(nil)
      selected_node.children.push(css_select(selector).first)    
      assert_contentful(selected_node, label)
    end

    private
    def register_contentful_label(label)
      @contentful_labels = Array.new if @contentful_labels.nil?
      @contentful_labels.push(label)
      if @contentful_labels.size > 1 && @contentful_labels.include?(nil)
        raise LabelError::new("Missing label")
      elsif @contentful_labels.uniq.size != @contentful_labels.size
        raise LabelError.new("Duplicate: '#{label}' already used")
      end
    end

    def register_contentful_format
      @contentful_format = response_is_xml ? 'xml' : 'html'
    end
  
    def parse_html(source, &invalid_html_handler)
      require 'bugfix_html_document_parsing_of_empty_tag_pair'
      HTML::Document.new(source, true, response_is_xml).root
    rescue RuntimeError => e
      raise invalid_html_handler.call(e.message)
    end

    def response_is_xml
      content_type_headers = []
      @response.headers.each do |header, value|
        content_type_headers.push(value) if header =~ /type$/i
      end unless @response.headers.nil?
      return !content_type_headers.grep(/xml/).empty?
    end

    def parsed_response_body
      parse_html(@response.body) do |message|
        Test::Unit::AssertionFailedError.new("Invalid mark-up in content:\n#{message}")
      end
    end

    def insert_linebreaks_to_make_html_diffable(html)
      html.gsub(/</, "\n<").gsub(/>/, ">\n").gsub(%r{(\n<\w+) (.+?)(/?>\n)}) do |tag|
        opening = $1
        all_attributes = $2
        closing = $3
        attribute_hash = Hash.new
        while all_attributes.sub!(%r{(\w+)="(.*?)"}, '') do
          attribute_hash[$1] = $2
        end
        if attribute_hash.size > 1
          tag = opening + "\n"
          attribute_hash.keys.sort.each do |attribute|
            tag += ' ' + attribute + '="' + attribute_hash[attribute] + '"' + "\n"
          end
          tag + closing
        else
          tag
        end
      end
    end

    def write_node_file(path, node)
      File.open(path, 'w') { |created_file| created_file.write(node.to_s) }
    end

    def write_node_diffable(path, node)
      File.open(path, 'w') do |file|
        file.write(insert_linebreaks_to_make_html_diffable(node.to_s))
      end
    end

    def contentful_expected_file
      contentful_prefix + 'expected.' + @contentful_format
    end

    def contentful_changed_file
      contentful_prefix + 'changed.' + @contentful_format
    end

    def contentful_expected_diffable
      contentful_prefix + 'expected.to_diff'
    end

    def contentful_changed_diffable
      contentful_prefix + 'changed.to_diff'
    end

    def contentful_relative_prefix
      contentful_prefix_in(
        Pathname.relative_to('.', contentful_testmethod_directory)
      )
    end

    def contentful_prefix
      contentful_prefix_in(contentful_testmethod_directory)
    end

    def contentful_prefix_in(directory)
      label = @contentful_labels.last
      File.join(directory, label.nil? ? '' : label.to_s + '.')
    end

    def contentful_testmethod_directory
      File.join(contentful_testcase_directory, method_name.sub(/^test_/, ''))
    end
      
    def contentful_testcase_directory
      File.join(BASE_DIRECTORY, self.class.to_s.sub(/Test$/, '').underscore)
    end

    def add_contentful_generation(file)
      @_result.add_contentful_generation(name, file)
    end
    private :add_contentful_generation
  end
end
        
