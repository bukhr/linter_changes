# lib/linter_changes/linter/rubocop/adapter.rb

module LinterChanges
  module Linter
    module RuboCop
      class Adapter < Base
        def list_target_files
          cmd = "#{@base_command} --list-target-files"
          Logger.debug "Executing command: #{cmd}"

          stdout, stderr, status = Open3.capture3(cmd)
          unless status.success?
            Logger.error "Error listing RuboCop target files: #{stderr}"
            exit 1
          end

          stdout.strip.split("\n")
        end

        def config_changed?
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
      end
    end
  end
end
