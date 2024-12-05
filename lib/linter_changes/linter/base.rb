# typed: true

module LinterChanges
  module Linter
    class Base
      extend T::Sig
      attr_reader :name

      sig { params(config_files: T::Array[String], command: String, force_global: T::Boolean).void }
      def initialize(config_files:, command:, force_global:)
        @name = T.must(self.class.name).split('::')[-2].then do |adapter_name|
          T.must(adapter_name).downcase
        end
        @config_files = config_files
        @command = command
        @base_command = @command.split(' ').first # used for listing files with in the adaptars
        @target_branch = ENV['CHANGE_TARGET']
        # We force origin if the target_branch is present
        @target_branch = "origin/#{@target_branch}" if !@target_branch.nil? && !@target_branch['origin']
        @git_diff = GitDiff.new(target_branch: @target_branch) if @target_branch
        @force_global = force_global || @target_branch.nil?
        @force_global = true unless @git_diff&.references_exists?
      end

      sig { returns(T::Array[String]) }
      def changed_files
        @git_diff.changed_files
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
        if @force_global
          if @target_branch.nil?
            Logger.debug "[#{name.capitalize}] No git branch provided by CHANGE_TARGET enviroment variable, \\
              running globally."
          elsif !@git_diff.references_exists?
            Logger.debug "[#{name.capitalize}] Some git reference does not exists locally. Forced to run globally"
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

      sig { params(command: String).returns(T::Boolean) }
      def execute_linter(command)
        Logger.debug "[#{name.capitalize}] Executing command: #{command}"
        !!system(command)
      end
    end
  end
end
