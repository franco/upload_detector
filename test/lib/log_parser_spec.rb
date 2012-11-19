$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

class LogEntryParserDouble
  def parse_line line
    nil
  end
end

class Listener

  %w[ on_processing_line on_ignored_line on_invalid_line on_matched_line ].each do |event|
    define_method event do |args|
      events[event.to_sym] = args
    end
  end

  def events; @events ||= {}; end

  def must_have_received event, args
    events.must_include event
    events[event].must_equal args
  end
end

describe LogParser do
  before do
    @log_entry_parser = LogEntryParserDouble.new
    @parser = LogParser.new log_io: ['log_statement'], log_entry_parser: @log_entry_parser
  end

  describe "#each" do
    before do
      @listener = Listener.new
      @parser.add_listener @listener
    end

    it "notifies on processing_line" do
      @parser.each
      @listener.must_have_received :on_processing_line, @parser
    end

    it "yields a log_entry on matched_line" do
      @log_entry_parser.stub :parse_line, '<log_entry>' do |*args|
        @parser.each do |log_entry|
          log_entry.must_equal '<log_entry>'
        end
      end
    end

    it "notifies on matched_line" do
      @log_entry_parser.stub :parse_line, '<log_entry>' do |*args|
        @parser.each
        @listener.must_have_received :on_matched_line, @parser
      end
    end

    it "notifies on ignored_line" do
      @log_entry_parser.stub :parse_line, nil do |*args|
        @parser.each
        @listener.must_have_received :on_ignored_line, @parser
      end
    end

    it "notifies on invalid_line" do
      @log_entry_parser.stub :parse_line, proc{ raise ParserError::InvalidFormatError} do |*args|
        @parser.each
        @listener.must_have_received :on_invalid_line, @parser
      end
    end
  end

  describe "#log_entry_parser" do
    it "builds a LogEntryParser object" do
      parser = LogParser.new log_format: 'sftp'
      parser.log_entry_parser.must_be_instance_of SftpLogFormatParser
    end
  end
end
