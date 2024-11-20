# lib/your_linter_gem/git_diff.rb

require 'open3'

module LinterChanges
  class GitDiff
    DEFAULT_TARGET_BRANCH = 'main'

    def initialize(target_branch: nil)
      @target_branch = target_branch || ENV['CHANGE_TARGET'] || DEFAULT_TARGET_BRANCH
      Logger.debug "Target branch: #{@target_branch}"
    end

    def changed_files
      binding.pry
      cmd = "git diff --name-only #{@target_branch}...HEAD"
      Logger.debug "Executing command: #{cmd}"

      stdout, stderr, status = Open3.capture3(cmd)
      unless status.success?
        Logger.error "Error obtaining git changes: #{stderr}"
        exit 1
      end

      files = stdout.strip.split("\n")
      Logger.debug "Changed files: #{files.join(', ')}"
      files
    end
  end
end
