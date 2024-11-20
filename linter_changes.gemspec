# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name = 'linter_changes'
  spec.version = LinterChanges::VERSION
  spec.authors = ['Jose Lara']
  spec.email = ['jvlara@uc.cl']

  spec.summary = 'Runs linters on code changes based on Git, either globally or only on modified files, depending on the changes.'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/bukhr/linter_changes'
  spec.required_ruby_version = ['>= 3.0', '< 4.0']
  spec.bindir = 'bin'
  spec.executables = ['linter_changes']

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |file|
      file.start_with?(*%w[.git Gemfile Rakefile
                           linter_changes- linter_changes.gemspec test helpers .rubocop.yml .ruby-version CHANGELOG CODE_OF_CONDUCT.md
                           CONTRIBUTING.md LICENSE])
    end
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 5.0', '< 8.0'
  spec.add_runtime_dependency 'open3'
  spec.add_runtime_dependency 'thor', '~> 1.0'

  spec.add_development_dependency 'activesupport', '~> 7'
  spec.add_development_dependency 'minitest', '~> 5.24.1'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rexml'
  spec.add_development_dependency 'rubocop', '~> 1.63.4'
  spec.add_development_dependency 'shoulda-context', '~> 3.0.0.rc1'
  spec.add_development_dependency 'shoulda-matchers', '~> 6.0'
end
