module Test
  module Unit
    class ContentfulGeneration
      attr_reader :test_name, :filename
      
      SINGLE_CHARACTER = '!'

      def initialize(test_name, filename)
        @test_name = test_name
        @filename = filename
      end

      def single_character_display
        SINGLE_CHARACTER
      end

      def message
        "Generated " + @filename
      end

      def short_display
        "#{@test_name}:\n" + message
      end

      def long_display
        "Contentful Notification:\n" + short_display
      end

      def to_s
        long_display
      end
    end

    class TestResult
      def add_contentful_generation(name, filename)
        # Not really a fault, but such is the hook the test framework provides.
        notify_listeners(FAULT, ContentfulGeneration.new(name, filename))
      end
    end
  end
end

