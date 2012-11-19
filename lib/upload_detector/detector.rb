require 'simple_observer'

# Detects uploads in a log file
class Detector
  include SimpleObserver::Observable

  attr_accessor :log_parser, :session_manager

  def initialize args
    @session_manager = args[:session_manager] || SessionManager.new(builder: Session) # TODO shouldn't we pass a factory instead of a class name?
    @log_parser = args[:log_parser] || LogParser.new(log_io: args[:log_file])
    @log_parser.add_listener self
  end

  def detect
    log_parser.each do |log_entry|
      apply_entry_to_session log_entry
    end
  end

  # forward parser callbacks
  %w[ on_processing_line on_ignored_line on_invalid_line ].each do |callback|
    define_method callback do |parser|
      notify_listeners callback.to_sym, line: parser.line
    end
  end

  private

  def apply_entry_to_session log_entry
    session = session_manager.session_for log_entry.session_id
    session.process log_entry
    if session.has_uploaded_files?
      notify_listeners :on_files_uploaded, account: session.account, uploaded_files: session.uploaded_files, uploaded_at: session.uploaded_at
    end
  end
end

