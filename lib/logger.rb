# lib/your_linter_gem/logger.rb

module LinterChanges
  class Logger
    class << self
      attr_accessor :debug_mode

      def debug(message)
        puts "[DEBUG] #{message}" if debug_mode
      end

      def error(message)
        puts "[ERROR] #{message}"
      end
    end
  end
end
