module Contentful
  class DiffHelper
    def self.command
      result = ENV['DIFF'].to_s
      result = 'diff' if result.empty?
      result
    end

    def self.command_line(prefix)
      "#{command} #{prefix}*.to_diff"
    end

    def self.run(prefix)
      Kernel.system(command_line(prefix))
    end
  end
end
