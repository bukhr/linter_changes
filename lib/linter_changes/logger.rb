# typed: true

module LinterChanges
  class Logger
    class << self
      extend T::Sig
      attr_accessor :debug_mode

      sig { params(message: String).void }
      def debug(message)
        puts "[DEBUG] #{message}" if debug_mode
      end

      sig { params(message: String).void }
      def error(message)
        puts "[ERROR] #{message}"
      end
    end
  end
end
