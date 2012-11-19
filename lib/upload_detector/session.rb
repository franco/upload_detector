class Session
  OPEN = :open_session
  CLOSE = :close_session
  UPLOAD = :upload_file
  RENAME = :rename_file

  attr_accessor :account, :session_id, :uploaded_files, :uploaded_at

  def initialize session_id, session_manager
    @session_id, @session_manager = session_id, session_manager
  end

  def process log_entry
    case log_entry.cmd
    when OPEN, CLOSE, UPLOAD, RENAME
      __send__ log_entry.cmd, log_entry
    end
  end

  def closed?
    @closed ||= false
  end

  def has_uploaded_files?
    closed? && @uploaded_files
  end

  def uploaded_files
    @uploaded_files ||= []
  end

  private

  def open_session log_entry
    self.account = log_entry.account
  end

  def upload_file log_entry
    uploaded_files << log_entry.file
  end

  def close_session log_entry
    self.uploaded_at = log_entry.time
    @session_manager.free_session session_id
    @closed = true
  end

  def rename_file log_entry
    if index = uploaded_files.index(log_entry.file)
      uploaded_files[index] = log_entry.renamed_to
    end
  end
end


