$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

RunnerDouble = Struct.new :config

describe ImportRunnerFactory do

  describe ".build" do
    it "creates a new runner instance using the runner class defined in the config" do
      config = { runner: 'RunnerDouble' }
      runner = ImportRunnerFactory.build config
      runner.class.to_s.must_equal config[:runner]
      runner.config.must_equal config
    end
  end
end

