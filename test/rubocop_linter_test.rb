# test/rubocop_linter_test.rb

require 'test_helper'

class RuboCopLinterTest < Minitest::Test
  context 'LinterChanges::Linter::RuboCopLinter' do
    setup do
      @linter = LinterChanges::Linter::RuboCopLinter.new
    end

    should 'use default config files and command' do
      assert_equal ['.rubocop.yml', 'Gemfile.lock'], @linter.instance_variable_get(:@config_files)
      assert_equal 'rubocop', @linter.instance_variable_get(:@command)
    end

    should 'allow custom config files and command' do
      linter = LinterChanges::Linter::RuboCopLinter.new(
        config_files: ['custom.yml'],
        command: 'rubocop --parallel'
      )
      assert_equal ['custom.yml'], linter.instance_variable_get(:@config_files)
      assert_equal 'rubocop --parallel', linter.instance_variable_get(:@command)
    end

    should 'list target files' do
      LinterChanges::Logger.stubs(:debug)
      expected_files = ['app/models/user.rb', 'app/controllers/users_controller.rb']
      Open3.expects(:capture3).with('rubocop --list-target-files')
           .returns([expected_files.join("\n"), '', mock(success?: true)])

      target_files = @linter.list_target_files
      assert_equal expected_files, target_files
    end

    should 'detect config changes' do
      changed_files = ['Gemfile.lock', 'app/models/user.rb']
      assert @linter.config_changed?(changed_files)
    end

    should 'not detect config changes when there are none' do
      changed_files = ['app/models/user.rb']
      refute @linter.config_changed?(changed_files)
    end

    should 'run linter successfully' do
      LinterChanges::Logger.stubs(:debug)
      @linter.expects(:system).with('rubocop app/models/user.rb').returns(true)
      assert @linter.run(files: ['app/models/user.rb'])
    end

    should 'handle linter failures' do
      LinterChanges::Logger.stubs(:debug)
      @linter.expects(:system).with('rubocop app/models/user.rb').returns(false)
      refute @linter.run(files: ['app/models/user.rb'])
    end
  end
end