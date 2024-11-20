# test/cli_test.rb

require 'test_helper'

class CLITest < Minitest::Test
  # TODO: test target_branch
  context 'LinterChanges::CLI' do
    setup do
      @argv = ['lint']
      @cli = LinterChanges::CLI
      LinterChanges::Logger.stubs(:debug)
    end

    should 'run with default options' do
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:config_changed?).returns(false)
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:list_target_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:run).returns(true)

      begin
        @cli.start(@argv)
      rescue SystemExit => e
        assert_equal 0, e.status, 'Expected exit code to be 0'
      end
    end

    should 'handle linter failures' do
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:config_changed?).returns(false)
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:list_target_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:run).returns(false)

      begin
        @cli.start(@argv)
      rescue SystemExit => e
        assert_equal 1, e.status, 'Expected exit code to be 1 on linter failure'
      end
    end

    should 'accept custom linters' do
      @argv = ['lint', '--linters', 'rubocop']
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:config_changed?).returns(false)
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:list_target_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:run).returns(true)

      begin
        @cli.start(@argv)
      rescue SystemExit => e
        assert_equal 0, e.status, 'Expected exit code to be 0'
      end
    end

    should 'handle unknown linter' do
      @argv = ['lint', '--linters', 'unknown_linter']
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      LinterChanges::Logger.expects(:error).with('Unknown linter specified: unknown_linter')

      begin
        @cli.start(@argv)
      rescue SystemExit => e
        assert_equal 1, e.status, 'Expected exit code to be 1 on linter failure'
      end
    end

    should 'pass custom config files and commands to linters' do
      @argv = [
        'lint',
        '--linters', 'rubocop',
        '--config-files', 'rubocop:.rubocop.yml,custom.yml',
        '--linter-command', 'rubocop:rubocop --parallel'
      ]
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.expects(:initialize).with(
        config_files: ['.rubocop.yml', 'custom.yml'],
        command: 'rubocop --parallel',
        git_diff: anything
      ).returns(nil)
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:config_changed?).returns(false)
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:list_target_files).returns(['app/models/user.rb'])
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:run).returns(true)
      LinterChanges::Linter::RuboCop::Adapter.any_instance.stubs(:name).returns('rubocop')
      begin
        @cli.start(@argv)
      rescue SystemExit => e
        assert_equal 0, e.status, 'Expected exit code to be 0'
      end
    end
  end
end
