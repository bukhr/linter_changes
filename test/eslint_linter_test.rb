# test/eslint_linter_test.rb

require 'test_helper'
class EslintLinterTest < Minitest::Test
  context 'LinterChanges::Linter::Eslint::Adapter' do
    setup do
      ENV['CHANGE_TARGET'] = 'master'
      LinterChanges::GitDiff.any_instance.stubs(:changed_files)
                            .returns(['app/assets/foo.js', 'app/models/user.rb', 'app/components/bar.vue'])
      LinterChanges::GitDiff.any_instance.stubs(:reference_exists?).returns(true)
      @linter = LinterChanges::Linter::Eslint::Adapter.new command: 'bin/eslint', force_global: false,
                                                           config_files: ['\.eslintrc\.js', 'package\.json', 'yarn\.lock']
    end

    should 'use default config files and command' do
      assert_equal ['\.eslintrc\.js', 'package\.json', 'yarn\.lock'], @linter.instance_variable_get(:@config_files)
      assert_equal 'bin/eslint', @linter.instance_variable_get(:@command)
    end

    should 'list only files with linted extensions' do
      LinterChanges::GitDiff.any_instance.stubs(:changed_files)
                            .returns(['app/assets/foo.js', 'app/models/user.rb', 'app/components/bar.vue',
                                      'app/assets/baz.ts', 'app/components/qux.tsx'])
      assert_equal ['app/assets/foo.js', 'app/components/bar.vue', 'app/assets/baz.ts', 'app/components/qux.tsx'],
                   @linter.list_target_files
    end

    should 'detect config changes when eslintrc changes' do
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['.eslintrc.js'])
      assert @linter.config_changed?
    end

    should 'detect config changes when package.json changes' do
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['package.json'])
      assert @linter.config_changed?
    end

    should 'not detect config changes when there are none' do
      refute @linter.config_changed?
    end

    should 'run linter only on changed js and vue files' do
      LinterChanges::Logger.stubs(:debug)
      @linter.expects(:system).with('bin/eslint app/assets/foo.js app/components/bar.vue').returns(true)
      assert @linter.run
    end

    should 'pass when no js files changed' do
      LinterChanges::Logger.stubs(:debug)
      LinterChanges::GitDiff.any_instance.stubs(:changed_files).returns(['app/models/user.rb'])
      @linter.expects(:system).never
      assert @linter.run
    end

    should 'handle linter failures' do
      LinterChanges::Logger.stubs(:debug)
      @linter.expects(:system).with('bin/eslint app/assets/foo.js app/components/bar.vue').returns(false)
      refute @linter.run
    end
  end
end
