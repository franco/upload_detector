$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

class UploadListenerDouble
  attr_reader :account, :uploaded_files
  def on_files_uploaded account, files
    @account = account
    @uploaded_files = files
  end
end

describe "parsing a single session" do
  it "works" do
    log_file = Fixture.load 'single_session_with_xml_files.log'

    upload_listener = UploadListenerDouble.new

    processor = Processor.new log: log_file
    processor.add_listener upload_listener
    UploadDetector.new( :processor => processor ).run(false)

    upload_listener.uploaded_files.must_equal [
     "/incoming/a_20121108_018.pdf", "/incoming/a_20121108_018.xml",
     "/incoming/a_20121108_019.pdf", "/incoming/a_20121108_019.xml" ]
  end
end

describe "parsing a single session with some files renamed" do
  it "works" do
    log_file = Fixture.load 'single_session_with_renaming_files.log'

    upload_listener = UploadListenerDouble.new

    processor = Processor.new log: log_file
    processor.add_listener upload_listener
    UploadDetector.new( :processor => processor ).run(false)

    upload_listener.uploaded_files.must_equal [
      "/incoming/TS_20121108_1.pdf", "/incoming/TS_20121108_10.pdf",
      "/incoming/TS_20121108_11.pdf", "/incoming/TS_20121108_12.pdf"]
  end
end


