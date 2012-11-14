class SftpLogFormatParser

  LogEntry = Struct.new(:log_stmt, :time, :session_id, :info) do
    def cmd
      case info
      when SESSION_OPEN_CMD_REGEXP
        'open_session'
      when SESSION_CLOSE_CMD_REGEXP
        'close_session'
      when SESSION_CLOSE_FILE_REGEXP
        'file_written'
      end
    end

    def account
      @account ||= ACCOUNT_REGEXP.match(info){ |m| m[1] }
    end

    def file
      @file ||= FILE_REGEXP.match(info){ |m| m[1] }
    end
  end

  TIME = '(?<time>\w{3}\s+\d{1,2}\s\d{2}:\d{2}:\d{2})'
  HOST = '(?<host>[-\w]+)?'
  PROCESS = '(?<process>[-\w]+)'
  PID = '\[(?<pid>\d+)\]'
  INFO = ':\s*(?<info>.+)$'

  REGEX_LOG_ENTRY = /^\s*#{TIME}\s#{HOST}\s#{PROCESS}#{PID}#{INFO}/
  ACCOUNT_REGEXP = /for\slocal\suser\s([-|\w]+)\sfrom/
  FILE_REGEXP = /"([^"]+)"/
  SESSION_OPEN_CMD_REGEXP = /^session\sopened/
  SESSION_CLOSE_CMD_REGEXP = /^session\sclosed/
  SESSION_CLOSE_FILE_REGEXP = /^\bclose\b.*read\s0/

  def parse string
    match = REGEX_LOG_ENTRY.match(string)

    # wrong format could indicated that openssh changed format of log statements?
    if match.nil?
      logger.debug{ "Log statement does not match expected format: '#{string}'" }
      raise ParserError::InvalidFormatError.new 'Does not match the expected format:'
    end

    # ignore non sftp entries (e.g. sshd)
    unless match[:process] == 'internal-sftp'
      logger.debug{ "Log statement ignored: '#{string}'" }
      return nil
    end

    logger.debug{ "Log statement matched: #{match.inspect}" }

    LogEntry.new string, match[:time], match[:pid], match[:info]
  end
end
