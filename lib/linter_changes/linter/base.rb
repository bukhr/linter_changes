# lib/linter_changes/linter/base.rb

module LinterChanges
  module Linter
    class Base
      attr_reader :name

      def initialize(config_files:, command:, force_global:)
        @name = self.class.name.split('::')[-2].downcase
        @config_files = config_files
        @command = command
        @base_command = @command.split(' ').first # used for listing files with in the adaptars
        @target_branch = ENV['CHANGE_TARGET']
        @git_diff = GitDiff.new(target_branch: @target_branch)
        @force_global = force_global || @target_branch.nil?
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
        @config_files.any? do |pattern|
          changed_files.any? { |file| file.match? Regexp.new(pattern) }
        end
      end

      # Runs the linter on the specified files
      def run
        if @force_global
          if @target_branch.nil?
            Logger.debug "[#{name.capitalize}] No git branch provided, forced to run globally."
          else
            Logger.debug "[#{name.capitalize}] Forced to run globally."
          end
          execute_linter(@command)
        elsif config_changed?
          Logger.debug "[#{name.capitalize}] Configuration changed. Running linter globally."
          execute_linter(@command)
        else
          files_to_lint = list_target_files & changed_files
          if files_to_lint.empty?
            Logger.debug "No files to lint for [#{name.capitalize}]."
            true
          else
            Logger.debug "Linting files with [#{name.capitalize}]: #{files_to_lint.join(', ')}"
            execute_linter("#{@command} #{files_to_lint.join(' ')}")
          end
        end
      end

      private

      def execute_linter(command)
        Logger.debug "[#{name.capitalize}] Executing command: #{command}"
        system(command)
      end
    end
  end
end
