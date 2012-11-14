class SessionManager

  attr_reader :sessions
  private :sessions

  def initialize args={}
    @session_builder = args[:builder] || Session
    @sessions = {}
  end

  def session_for session_id
    sessions[session_id] ||= @session_builder.new session_id, self
  end

  def free_session(session_id)
    sessions.delete session_id
  end
end
