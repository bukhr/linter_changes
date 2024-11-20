# lib/linter_changes/cli.rb

require 'bundler/setup'
require 'thor'
require_relative 'git_diff'
require_relative 'logger'
require_relative 'linter/base'
require_relative 'linter/rubocop_linter'
require 'pry-byebug'

module LinterChanges
  class CLI < Thor
    class_option :debug, type: :boolean, default: false, desc: 'Enable debug mode'
    class_option :target_branch, type: :string, default: nil, desc: 'Specify the target branch'

    desc 'lint', 'Run linters on changed files'
    method_option :linters, type: :array, default: [], desc: 'Specify linters to run (e.g., rubocop,eslint)'
    method_option :config_files, type: :hash, default: {},
                                 desc: 'Specify config files per linter (e.g., rubocop=.rubocop.yml)'
    method_option :linter_command, type: :hash, default: {},
                                   desc: 'Specify command per linter (e.g., rubocop="rubocop --parallel")'
    def lint
      Logger.debug_mode = options[:debug]

      git_diff = GitDiff.new(target_branch: options[:target_branch])
      changed_files = git_diff.changed_files
      linters = select_linters git_diff
      overall_success = true

      linters.each do |linter|
        Logger.debug "Running #{linter.name.capitalize} linter"
        if linter.config_changed?(changed_files)
          Logger.debug "#{linter.name.capitalize} configuration changed. Running linter globally."
          success = linter.run
        else
          files_to_lint = linter.list_target_files & changed_files
          if files_to_lint.empty?
            Logger.debug "No files to lint for #{linter.name.capitalize}."
            next
          else
            Logger.debug "Linting files with #{linter.name.capitalize}: #{files_to_lint.join(', ')}"
            success = linter.run(files: files_to_lint)
          end
        end

        overall_success &&= success
      end

      exit(overall_success ? 0 : 1)
    end

    def self.exit_on_failure?
      true
    end

    no_commands do
      def select_linters git_diff
        linter_names = if options[:linters].empty?
                         AVAILABLE_LINTERS.keys
                       else
                         options[:linters]
                       end
        linter_names.map do |name|
          klass = AVAILABLE_LINTERS[name]
          unless klass
            Logger.error "Unknown linter specified: #{name}"
            exit 1
          end

          # Pass custom config files and commands if provided
          config_files = parse_config_files_option(name)
          command = options[:linter_command][name]
          klass.new(config_files:, command:, git_diff:)
        end
      end

      def parse_config_files_option(linter_name)
        config_files_option = options[:config_files][linter_name]
        return nil unless config_files_option

        config_files_option.split(',')
      end
    end

    AVAILABLE_LINTERS = {
      'rubocop' => LinterChanges::Linter::RuboCopLinter
    }.freeze
  end
end
