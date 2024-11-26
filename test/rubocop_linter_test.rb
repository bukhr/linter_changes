# test/rubocop_linter_test.rb

require 'test_helper'
class RuboCopLinterTest < Minitest::Test
  context 'LinterChanges::Linter::RuboCop::Adapter' do
    setup do
      ENV['CHANGE_TARGET'] = 'master'
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      LinterChanges::GitDiff.any_instance.stubs(:changed_lines_contains?).returns(false)
      LinterChanges::GitDiff.any_instance.stubs(:reference_exists?).returns(true)
      result_mock = mock
      result_mock.stubs(:success?).returns(true)
      target_files_rubocop = ['rubocop.yml', 'app/models/user.rb', 'app/controllers/users_controller.rb']
      Open3.stubs(:capture3).with('bin/rubocop --list-target-files')
           .returns([target_files_rubocop.join("\n"), '', result_mock])
      @linter = LinterChanges::Linter::RuboCop::Adapter.new command: 'bin/rubocop', force_global: false,
                                                            config_files: ['rubocop']
    end

    # TODO: test gemfile behaviour
    should 'use default config files and command' do
      assert_equal ['rubocop'], @linter.instance_variable_get(:@config_files)
      assert_equal 'bin/rubocop', @linter.instance_variable_get(:@command)
    end

    should 'allow custom config files and command' do
      linter = LinterChanges::Linter::RuboCop::Adapter.new(
        config_files: ['custom.yml'],
        command: 'rubocop --parallel',
        force_global: false
      )
      assert_equal ['custom.yml'], linter.instance_variable_get(:@config_files)
      assert_equal 'rubocop --parallel', linter.instance_variable_get(:@command)
    end

    should 'list target files' do
      LinterChanges::Logger.stubs(:debug)
      expected_files = ['app/models/user.rb', 'app/controllers/users_controller.rb']
      Open3.expects(:capture3).with('bin/rubocop --list-target-files')
           .returns([expected_files.join("\n"), '', mock(success?: true)])

      target_files = @linter.list_target_files
      assert_equal expected_files, target_files
    end

    should 'detect config changes' do
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['rubocop.yml'])
      assert @linter.config_changed?
    end

    should 'not detect config changes when there are none' do
      refute @linter.config_changed?
    end

    should 'run linter successfully' do
      LinterChanges::Logger.stubs(:debug)
      @linter.expects(:system).with('bin/rubocop app/models/user.rb').returns(true)
      assert @linter.run
    end

    should 'handle linter failures' do
      LinterChanges::Logger.stubs(:debug)
      expected_files = ['app/models/user.rb']
      Open3.expects(:capture3).with('bin/rubocop --list-target-files')
           .returns([expected_files.join("\n"), '', mock(success?: true)])
      @linter.expects(:system).with('bin/rubocop app/models/user.rb').returns(false)
      refute @linter.run
    end
  end
end
