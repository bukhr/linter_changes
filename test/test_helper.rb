# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

ENV['RACK_ENV'] ||= 'test'

require 'bundler/setup'
Bundler.require(:default, :development, ENV['RACK_ENV'] || :development)

require 'minitest/autorun'
require 'mocha/minitest'
require 'shoulda/matchers'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
  end
end

require 'linter_changes/git_diff'
require 'linter_changes/logger'
require 'linter_changes/linter/base'
require 'linter_changes/linter/rubocop/adapter'
require 'linter_changes/cli'
