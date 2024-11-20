# lib/linter_changes/linter/base.rb

module LinterChanges
  module Linter
    class Base
      attr_reader :name

      def initialize(config_files: nil, command: nil, target_branch: nil, force_global: false)
        @name = self.class.name.split('::')[-2].downcase
        config_file_path = File.expand_path("#{@name}/default_config.yml", __dir__)
        default_config_file = YAML.load_file(config_file_path)
        @config_files = config_files || default_config_file['config_files']
        @command = command || default_config_file['command']
        @base_command = @command.split(' ').first
        @git_diff = GitDiff.new(target_branch:)
        @force_global = force_global
      end

      def changed_files
        @git_diff.changed_files
      end

      # Returns an array of files that the linter targets
      def list_target_files
        raise NotImplementedError, "#{self.class} must implement #list_target_files"
      end

      # Checks if any configuration files have changed
      def config_changed?
        changed = @config_files.any? do |pattern|
          changed_files.any? { |file| file.match? Regexp.new(pattern) }
        end
        changed
      end

      # Runs the linter on the specified files
      def run
        if @force_global
          Logger.debug "#{name.capitalize} forced to run globally."
          execute_linter(@command)
        elsif config_changed?
          Logger.debug "#{name.capitalize} configuration changed. Running linter globally."
          execute_linter(@command)
        else
          files_to_lint = list_target_files & changed_files
          if files_to_lint.empty?
            Logger.debug "No files to lint for #{name.capitalize}."
            true
          else
            Logger.debug "Linting files with #{name.capitalize}: #{files_to_lint.join(', ')}"
            execute_linter("#{@command} #{files_to_lint.join(' ')}")
          end
        end
      end

      private

      def execute_linter(command)
        Logger.debug "Executing RuboCop command: #{command}"
        system(command)
      end
    end
  end
end
