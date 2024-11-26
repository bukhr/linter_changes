# lib/your_linter_gem/git_diff.rb

require 'open3'

module LinterChanges
  class GitDiff
    def initialize(target_branch:)
      @target_branch = target_branch
    end

    def changed_files
      return @changed_files if defined? @changed_files

      Logger.debug "Target branch: #{@target_branch}"
      cmd = "git diff --name-only #{@target_branch}...HEAD"
      Logger.debug "Executing command: #{cmd}"

      stdout, stderr, status = Open3.capture3(cmd)
      unless status.success?
        Logger.error "Error obtaining git changes: #{stderr}"
        exit 1
      end

      @changed_files = stdout.strip.split("\n")
      Logger.debug "Changed files: #{@changed_files.join(', ')}"
      @changed_files
    end

    def changed_lines_contains? file:, pattern:
      cmd = "git diff #{@target_branch}...HEAD -- #{file}"
      stdout, stderr, status = Open3.capture3(cmd)
      unless status.success?
        Logger.error "Error obtaining git diff for #{file}: #{stderr}"
        exit 1
      end
      stdout.include? pattern
    end

    def reference_exists?(ref)
      system("git rev-parse --verify #{ref} > /dev/null 2>&1")
    end

    def references_exists?
      return @references_exist if defined?(@references_exists)

      @references_exist = if !reference_exists?(@target_branch)
                            Logger.debug("Reference for #{@target_branch} does not exists")
                            false
                          elsif !reference_exists?('HEAD')
                            Logger.debug('Reference for HEAD does not exists')
                            false
                          else
                            true
                          end
      @references_exist
    end
  end
end
