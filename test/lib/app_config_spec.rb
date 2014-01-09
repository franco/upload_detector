$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

describe AppConfig do
  describe "#merge!" do
    let(:config){ AppConfig.new filename: 'upload_detector.yml', env: 'test' }

    it "appends programmatically" do
      config.merge! new_entry: 'value'
      config.new_entry.must_equal 'value'
    end

    it "defines the additional config on the singleton class" do
      config.merge! new_entry: 'value'
      new_config = AppConfig.new filename: 'upload_detector.yml', env: 'test'
      new_config.wont_respond_to :new_entry
    end
  end
end

