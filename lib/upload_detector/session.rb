class Session
  OPEN = :open_session
  CLOSE = :close_session
  UPLOAD = :upload_file

  attr_accessor :account, :session_id, :uploaded_files

  def initialize session_id, session_manager
    @session_id, @session_manager = session_id, session_manager
  end

  def process log_entry
    case log_entry.cmd
    when OPEN, CLOSE, UPLOAD
      __send__ log_entry.cmd, log_entry
    end
  end

  def closed?
    @closed ||= false
  end

  def has_uploaded_files?
    closed? && @uploaded_files
  end

  private

  def open_session log_entry
    self.account = log_entry.account
  end

  def upload_file log_entry
    (@uploaded_files ||= []) << log_entry.file
  end

  def close_session log_entry
    @session_manager.free_session session_id
    @closed = true
  end

end


#class SftpSession

  #class ParseError < StandardError; end

  #attr_accessor :account, :session_id, :uploaded_files

  #class <<self
    #def get session_id
      #(@sessions ||= {} )[session_id] ||= self.new session_id
    #end
    #alias_method :[], :get

    #def remove session
      #@sessions.delete session.session_id
    #end
  #end

  #def initializer session_id
    #@session_id = session_id
  #end

  #def process_log_statement stmt
    #case stmt
    #when /^session\sopened/
      #self.account = extract_account stmt
    #when /^session\sclosed/
      #@closed = true
      #self.class.remove self
    #when /^\bclose\b.*read\s0/
      #(@uploaded_files ||= []) << extract_file(stmt)
    #else
      ## ignore event
    #end

    #self
  #end

  #def closed?
    #@closed ||= false
  #end

  #def has_uploaded_files?
    #closed? && @uploaded_files
  #end

  #private

  #def extract_account stmt
    #/for\slocal\suser\s([-|\w]+)\sfrom/.match(stmt) do |m|
      #m[1]
    #end or raise ParseError.new 'Could not parse account name'
  #end

  #def extract_file stmt
    #/\"([-|\w]+)\"/.match(stmt) do |m|
      #m[1]
    #end or raise ParseError.new 'Could not parse file name'
  #end

#end
