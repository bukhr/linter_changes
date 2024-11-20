# lib/linter_changes/linter/rubocop_linter.rb

module LinterChanges
  module Linter
    class RuboCopLinter < Base
      DEFAULT_CONFIG_FILES = ['.rubocop.yml', 'Gemfile.lock'].freeze
      DEFAULT_COMMAND = 'rubocop'

      def list_target_files
        cmd = "#{@command} --list-target-files"
        Logger.debug "Executing command: #{cmd}"

        stdout, stderr, status = Open3.capture3(cmd)
        unless status.success?
          Logger.error "Error listing RuboCop target files: #{stderr}"
          exit 1
        end

        files = stdout.strip.split("\n")
        Logger.debug "RuboCop target files: #{files.join(', ')}"
        files
      end

      def run(files: [])
        cmd = if files.empty?
                @command
              else
                "#{@command} #{files.join(' ')}"
              end
        execute_linter(cmd)
      end

      private

      def default_config_files
        DEFAULT_CONFIG_FILES
      end

      def default_command
        DEFAULT_COMMAND
      end

      def execute_linter(command)
        Logger.debug "Executing RuboCop command: #{command}"
        system(command)
      end
    end
  end
end
