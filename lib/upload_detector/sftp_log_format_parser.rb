require 'time'

class SftpLogFormatParser

  LogEntry = Struct.new(:log_stmt, :time, :session_id, :info) do
    def cmd
      case info
      when SESSION_OPEN_CMD_REGEXP
        Session::OPEN
      when SESSION_CLOSE_CMD_REGEXP
        Session::CLOSE
      when CLOSE_FILE_REGEXP
        Session::UPLOAD
      when RENAME_FILE_REGEXP
        Session::RENAME
      end
    end

    def account
      @account ||= ACCOUNT_REGEXP.match(info){ |m| m[1] }
    end

    def file
      @file ||= info.scan(FILE_REGEXP).flatten.first
    end

    def renamed_to
      @renamed_to ||= info.scan(FILE_REGEXP).flatten.last
    end
    def time
      Time.parse self[:time]
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
  CLOSE_FILE_REGEXP = /^\bclose\b.*read\s0/
  RENAME_FILE_REGEXP = /^\brename\b/

  def parse_line string
    match = REGEX_LOG_ENTRY.match(string) or raise ParserError::InvalidFormatError

    if match[:process] == 'internal-sftp'
      LogEntry.new string, match[:time], match[:pid], match[:info]
    else
      nil
    end
  end

end
