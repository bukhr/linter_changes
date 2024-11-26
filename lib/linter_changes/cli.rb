# lib/linter_changes/cli.rb

require 'bundler/setup'
require 'thor'
require_relative 'git_diff'
require_relative 'logger'
require_relative 'linter/base'
require_relative 'linter/rubocop/adapter'
require_relative 'config'

module LinterChanges
  class CLI < Thor
    class_option :debug, type: :boolean, default: false, desc: 'Enable debug mode'
    class_option :target_branch, type: :string, default: nil,
                                 desc: 'Specify the target branch, if nil, it will run globally'
    class_option :force_global, type: :boolean, default: false, desc: 'Run all linters on global configuration'

    method_option :linters, type: :array, default: [],
                            desc: 'Specify linters to run (e.g., rubocop,eslint). If no option provided, will run everything at config file'
    desc 'lint', 'Run linters on changed files'
    def lint
      Logger.debug_mode = options[:debug]

      @config = LinterChanges::Config.load
      overall_success = true

      select_linters.each do |linter|
        Logger.debug "Running #{linter.name.capitalize} linter"
        overall_success &&= linter.run
      end

      exit(overall_success ? 0 : 1)
    end

    def self.exit_on_failure?
      true
    end

    no_commands do
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

          # TODO: raise if no config files or command found
          config_files = @config[name]['config_files'] || []
          command = @config[name]['linter_command']
          klass.new(config_files:, command:, force_global: options[:force_global])
        end
      end
    end

    AVAILABLE_LINTERS = {
      'rubocop' => LinterChanges::Linter::RuboCop::Adapter
    }.freeze
  end
end
