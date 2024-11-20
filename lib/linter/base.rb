# lib/linter_changes/linter/base.rb

module LinterChanges
  module Linter
    class Base
      attr_reader :name

      def initialize(config_files: nil, command: nil, git_diff: nil)
        @name = self.class.name.split('::')[-2].downcase
        default_config_file = YAML.load_file("lib/linter/#{@name}/default_config.yml")
        @config_files = config_files || default_config_file['config_files']
        @command = command || default_config_file['command']
        @git_diff = git_diff
      end

      # Returns an array of files that the linter targets
      def list_target_files
        raise NotImplementedError, "#{self.class} must implement #list_target_files"
      end

      # Checks if any configuration files have changed
      def config_changed?(changed_files)
        changed = @config_files.any? do |pattern|
          changed_files.any? { |file| file.match? Regexp.new(pattern) }
        end
        Logger.debug "#{@name.capitalize} configuration changed: #{changed}"
        changed
      end

      # Runs the linter on the specified files
      def run(files: [])
        raise NotImplementedError, "#{self.class} must implement #run"
      end

      private

      def default_config_files
        raise NotImplementedError, "#{self.class} must implement #default_config_files"
      end

      def default_command
        raise NotImplementedError, "#{self.class} must implement #default_command"
      end
    end
  end
end
