# typed: true

module LinterChanges
  module Linter
    class Base
      extend T::Sig
      attr_reader :name

      sig do
        params(config_files: T::Array[String], command: String, force_global: T::Boolean,
               target_branch: T.nilable(String)).void
      end
      def initialize(config_files:, command:, force_global:, target_branch:)
        @name = T.must(self.class.name).split('::')[-2].then do |adapter_name|
          T.must(adapter_name).downcase
        end
        @config_files = config_files
        @command = command
        @base_command = @command.split(' ').first # used for listing files with in the adaptars
        @target_branch = target_branch
        @force_global = force_global
      end

      sig { returns(T::Array[String]) }
      def changed_files
        T.must(git_diff).changed_files
      end

      sig { returns(T.nilable(GitDiff)) }
      def git_diff
        return @git_diff if defined? @git_diff

        # We force origin if the target_branch is present
        @target_branch = "origin/#{@target_branch}" if !@target_branch.nil? && !@target_branch['origin']
        @git_diff = @target_branch ? GitDiff.new(target_branch: @target_branch) : nil
      end

      sig { returns(T::Boolean) }
      def force_global_run?
        return @force_global_run if defined? @force_global_run

        reason =
          if @target_branch.nil?
            'No git branch provided, running globally.'
          elsif !T.must(git_diff).references_exists?
            'Some git reference does not exist locally. Forced to run globally.'
          elsif @force_global
            'Forced to run globally.'
          elsif config_changed?
            'Configuration changed. Running linter globally.'
          end

        if reason
          Logger.debug "[#{name.capitalize}] #{reason}"
          true
        else
          false
        end
      end

      # Returns an array of files that the linter targets
      sig { returns(T::Array[String]) }
      def list_target_files
        raise NotImplementedError, "#{self.class} must implement #list_target_files"
      end

      # Checks if any configuration files have changed
      sig { returns(T::Boolean) }
      def config_changed?
        @config_files.any? do |pattern|
          changed_files.any? { |file| file.match? Regexp.new(pattern) }
        end
      end

      # Runs the linter on the specified files
      sig { returns(T::Boolean) }
      def run
        if force_global_run?
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

      sig { params(command: String).returns(T::Boolean) }
      def execute_linter(command)
        Logger.debug "[#{name.capitalize}] Executing command: #{command}"
        !!system(command)
      end
    end
  end
end
