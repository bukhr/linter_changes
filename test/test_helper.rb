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

require 'git_diff'
require 'logger'
require 'linter/base'
require 'linter/rubocop_linter'
require 'cli'
