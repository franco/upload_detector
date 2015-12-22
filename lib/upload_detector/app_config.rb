require 'yaml'
require 'active_support/core_ext/hash/keys'

class AppConfig
  attr_reader :data, :env
  def self.config_path
    File.join(File.dirname(__FILE__), '../..', 'config')
  end

  def initialize opts
    @env  = opts[:env] || 'development'
    @data = load_data opts[:filename]
    initial_data = opts[:initial_data] || {}
    data.merge!(initial_data.stringify_keys)
    define_methods_for_environment(data.keys)
  end

  def [](key)
    data[key.to_s]
  end

  def merge! hash
    data.merge! hash.stringify_keys
    define_methods_for_environment(data.keys)
  end

  private

  def load_data filename, env=@env
    yml = YAML::load_file(File.join(self.class.config_path, filename))
    yml[env]
  end

  def define_methods_for_environment names
    names.each do |name|
      unless respond_to? name
        self.singleton_class.class_eval <<-EOS
          def #{name}
            data['#{name}']
          end
        EOS
      end
    end
  end
end
