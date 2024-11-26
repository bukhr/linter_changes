# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

# require "rubocop/rake_task"

# RuboCop::RakeTask.new
#

namespace :release do
  desc 'Release the gem'
  task :push do
    version = LinterChanges::VERSION
    sh 'gem build linter_changes.gemspec'
    sh 'git add .'
    sh "git commit -m 'Release version #{version}'"
    sh "git tag -a v#{version} -m 'Release version #{version}'"
    sh 'git push origin master --tags'
    sh "gem push linter_changes-#{version}.gem"
  end
end

task default: %i[test]
