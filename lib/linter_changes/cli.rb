# typed: true

require 'bundler/setup'
require 'thor'
require_relative 'git_diff'
require_relative 'logger'
require_relative 'linter/base'
require_relative 'linter/rubocop/adapter'
require_relative 'config'

module LinterChanges
  class CLI < Thor
    extend T::Sig

    class_option :debug, type: :boolean, default: false, desc: 'Enable debug mode'
    class_option :force_global, type: :boolean, default: false, desc: 'Run all linters on global configuration'

    method_option :linters, type: :array, default: [],
                            desc: 'Specify linters to run (e.g., rubocop,eslint). If no option provided, \\
                                will run everything at config file'
    method_option :target_branch, type: :boolean, default: nil,
                                  desc: 'Specify target branch to compare with. If no option provided, \\
                                  will run globally'
    desc 'lint', 'Run linters on changed files'
    sig { returns(T.noreturn) }
    def lint
      Logger.debug_mode = options[:debug]

      @config = LinterChanges::Config.load
      overall_success = T.let(true, T::Boolean)

      select_linters.each do |linter|
        Logger.debug "Running #{linter.name.capitalize} linter"
        overall_success &&= linter.run
      end

      exit(overall_success ? 0 : 1)
    end

    sig { returns(T::Boolean) }
    def self.exit_on_failure?
      true
    end

    sig { returns(T::Array[LinterChanges::Linter::Base]) }
    def select_linters
      linter_names = @config.keys && options[:linters]
      if linter_names.empty?
        Logger.error 'No linters specified on configuration file.'
        exit 1
      end
      linter_names.map do |name|
        klass = AVAILABLE_LINTERS[name]
        unless klass
          Logger.error "Unknown linter specified: #{name}"
          exit 1
        end

        # TODO: raise if no command found
        config_files = @config[name]['config_files'] || []
        command = @config[name]['linter_command']
        klass.new(config_files:, command:, force_global: options[:force_global], target_branch: options[:target_branch])
      end
    end
    remove_command :select_linters

    AVAILABLE_LINTERS = {
      'rubocop' => LinterChanges::Linter::RuboCop::Adapter
    }.freeze
  end
end
