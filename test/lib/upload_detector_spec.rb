$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

class UploadListenerDouble
  attr_reader :account, :uploaded_files, :uploaded_at
  def on_files_uploaded args
    @account = args[:account]
    @uploaded_files = args[:uploaded_files]
    @uploaded_at = args[:uploaded_at]
  end
end

describe "parsing a single session" do
  it "works" do
    input_file = Fixture.load 'single_session_with_xml_files.log'

    upload_listener = UploadListenerDouble.new

    detector = Detector.new input_file: input_file, log_format: 'sftp'
    detector.add_listener upload_listener
    UploadDetector.new( daemonized: false ).run(detector)

    upload_listener.uploaded_files.must_equal [
     "/incoming/a_20121108_018.pdf", "/incoming/a_20121108_018.xml",
     "/incoming/a_20121108_019.pdf", "/incoming/a_20121108_019.xml" ]

    upload_listener.uploaded_at.must_equal Time.parse('Nov  8 04:37:36')
  end
end

describe "parsing a single session with some files renamed" do
  it "works" do
    input_file = Fixture.load 'single_session_with_renaming_files.log'

    upload_listener = UploadListenerDouble.new

    detector = Detector.new input_file: input_file, log_format: 'sftp'
    detector.add_listener upload_listener
    UploadDetector.new( daemonized: false ).run(detector)

    upload_listener.uploaded_files.must_equal [
      "/incoming/TS_20121108_1.pdf", "/incoming/TS_20121108_10.pdf",
      "/incoming/TS_20121108_11.pdf", "/incoming/TS_20121108_12.pdf"]
  end
end


