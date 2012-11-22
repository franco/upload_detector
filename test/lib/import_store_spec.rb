$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

describe ImportStore do
  before do
    @store = ImportStore.new location: File.join(File.dirname(__FILE__), '../../tmp', 'test.pstore' )
  end

  describe "#create_import" do
    it "creates a new import object from attributes and stores it" do
      import = @store.create_import upload_reference: '1', files: ['file1', 'file2']
      retrieved_import = @store.find '1'
      retrieved_import.must_equal import
    end
  end

  describe "find_or_create_import" do
    it "creates a new import if not existent" do
      import = @store.find_or_create_import upload_reference: '1', files: ['file1', 'file2']
      import.id.must_equal '1'
    end
    it "finds an existing import" do
      import = @store.create_import upload_reference: '1', files: ['file1', 'file2']
      retrieved_import = @store.find_or_create_import upload_reference: '1', files: []
      retrieved_import.must_equal import
    end
  end
end

