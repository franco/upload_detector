require 'yaml'
class AppConfig
  attr_reader :data, :env
  def self.config_path
    File.join(File.dirname(__FILE__), '../..', 'config')
  end

  def initialize opts
    @env = opts[:env] || 'development'
    filename = opts[:filename]
    yml = YAML::load_file(File.join(self.class.config_path, filename))
    initial_data = opts[:initial_data] || {}
    @data = yml[env].merge(initial_data)
    define_methods_for_environment(data.keys)
  end

  def define_methods_for_environment names
    names.each do |name|
      self.class.class_eval <<-EOS
        def #{name}
          data['#{name}']
        end
      EOS
    end
  end
end
