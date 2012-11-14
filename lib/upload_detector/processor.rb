# Processes the log file
class Processor
  attr_accessor :log, :log_format_parser
  attr_reader :session_manager
  private :session_manager

  def initialize args
    @log = args[:log]
    @log_format_parser = args[:parser] || SftpLogFormatParser.new
    @session_manager = SessionManager.new builder: Session # TODO shouldn't we pass a factory instead of a class name?
  end

  def run forever=true
    while !log.eof? || forever
      line = log.readline
      notify_listeners :on_process_line, line

      begin
        if log_entry = log_format_parser.parse( line )

          session = session_manager.session_for log_entry.session_id
          session.process log_entry

          if session.has_uploaded_files?
            notify_listeners :on_files_uploaded, session.account, session.uploaded_files
          end
        else
          notify_listeners :on_ignore_line, line
        end
      rescue ParserError::InvalidFormatError => e
        notify_listeners :on_invalid_line, line, e
      end
    end
  end

  def add_listener listener
    (@listeners ||= []) << listener
  end

  def notify_listeners event_name, *args
    @listeners && @listeners.each do |listener|
      if listener.respond_to? event_name
        listener.public_send event_name, *args
      end
    end
  end
end

