# test/git_diff_test.rb
require 'test_helper'

class GitDiffTest < Minitest::Test
  context 'LinterChanges::GitDiff' do
    setup do
      @target_branch = 'main'
      @git_diff = LinterChanges::GitDiff.new(target_branch: 'main')
    end

    should 'initialize with the correct target branch' do
      assert_equal 'main', @git_diff.instance_variable_get(:@target_branch)
    end

    should 'return changed files' do
      LinterChanges::Logger.stubs(:debug)
      expected_files = ['file1.rb', 'file2.rb']
      Open3.expects(:capture3).with("git diff --name-only #{@target_branch}...HEAD")
           .returns([expected_files.join("\n"), '', mock(success?: true)])

      changed_files = @git_diff.changed_files
      assert_equal expected_files, changed_files
    end

    should 'handle git command errors' do
      LinterChanges::Logger.stubs(:debug)
      Open3.expects(:capture3).with("git diff --name-only #{@target_branch}...HEAD")
           .returns(['', 'fatal: Not a git repository', mock(success?: false)])

      assert_raises(SystemExit) { @git_diff.changed_files }
    end
  end
end
