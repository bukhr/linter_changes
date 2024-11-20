# lib/linter_changes/linter/rubocop/adapter.rb

module LinterChanges
  module Linter
    module RuboCop
      class Adapter < Base
        # By default, anything containing rubocop on the file path will be consider a config file
        DEFAULT_CONFIG_FILES = [/rubocop/].freeze
        DEFAULT_COMMAND = 'bin/rubocop'.freeze

        def list_target_files
          cmd = "#{DEFAULT_COMMAND} --list-target-files"
          Logger.debug "Executing command: #{cmd}"

          stdout, stderr, status = Open3.capture3(cmd)
          unless status.success?
            Logger.error "Error listing RuboCop target files: #{stderr}"
            exit 1
          end

          stdout.strip.split("\n")
        end

        def run(files: [])
          cmd = if files.empty?
                  @command
                else
                  "#{@command} #{files.join(' ')}"
                end
          execute_linter(cmd)
        end

        def config_changed?(changed_files)
          # Check if any of the config files have changed
          return true if super

          # TODO: get the location of Gemfile.lock with bundle command
          # Check if Gemfile.lock has changed and contains something related to rubocop
          if changed_files.include?('Gemfile.lock') && @git_diff.changed_lines_contains?(file: 'Gemfile.lock',
                                                                                        pattern: 'rubocop')
            Logger.debug 'Something related to rubocop gem version changed in Gemfile.lock'
            return true
          end
          false
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
end
