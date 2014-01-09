$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

describe UploadReference do

  describe ".account_from_id" do
    it "parses the account name out from an id" do
      account = UploadReference.account_from_id('uusimaa-1389119318-a9660258')
      account.must_equal 'uusimaa'

      account = UploadReference.account_from_id('something-more-complex-1389119318-a9660258')
      account.must_equal 'something-more-complex'
    end
    it "returns nil if parsing failes" do
      account = UploadReference.account_from_id('invalid')
      account.must_be_nil
    end
  end
end

