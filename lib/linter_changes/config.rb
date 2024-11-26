# lib/linter_changes/config.rb

require 'yaml'

module LinterChanges
  class Config
    USER_CONFIG_PATH = File.join(Dir.pwd, '.linter_changes.yml')

    def self.load
      user_config = File.exist?(USER_CONFIG_PATH) ? YAML.load_file(USER_CONFIG_PATH) : nil
      unless user_config
        raise StandardError.new 'No configuration file provided, you need the file .linter_changes.yml at the base of your proyect'
      end

      user_config
    end
  end
end
