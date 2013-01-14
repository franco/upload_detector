require 'simple_observer'
class LogParser
  include SimpleObserver::Observable

  attr_reader :log_io, :log_format, :log_entry, :line

  def initialize args
    @log_io            = args[:log_io]
    @log_format        = args[:log_format] || 'sftp'
    @log_entry_parser  = args[:log_entry_parser] || log_entry_parser
  end

  def reload
    debugger
    log_io.reopen log_io.path
  end

  def each
    log_io.each do |line|
      @line = line
      notify_listeners :on_processing_line, self
      begin
        @log_entry = log_entry_parser.parse_line line
        if @log_entry
          yield @log_entry if block_given?
          notify_listeners :on_matched_line, self
        else
          notify_listeners :on_ignored_line, self
        end
      rescue ParserError::InvalidFormatError
        notify_listeners :on_invalid_line, self
      end
    end
  end

  def log_entry_parser
    @log_entry_parser ||= Object.const_get("#{@log_format.to_s.capitalize}LogFormatParser").new
  end
end
