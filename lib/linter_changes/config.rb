# typed: true

require 'yaml'

module LinterChanges
  class Config
    extend T::Sig
    USER_CONFIG_PATH = '.linter_changes.yml'

    sig { params(config_file: String).returns(T::Hash[String, T.untyped]) }
    def self.load config_file: USER_CONFIG_PATH
      config_file = File.join(Dir.pwd, config_file)
      user_config = File.exist?(config_file) ? YAML.load_file(config_file) : nil
      unless user_config
        raise StandardError.new 'No configuration file provided, you need the file .linter_changes.yml at the base of your proyect'
      end

      user_config
    end
  end
end
