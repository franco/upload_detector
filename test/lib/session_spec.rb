$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

LogEntryDouble = Struct.new :session_id, :cmd, :account, :file, :renamed_to, :time

describe Session do
  before do
    @session_manager = MiniTest::Mock.new
    @session_manager.expect :free_session, nil, ['1']
    @session = Session.new '1', @session_manager
    @log_entry = LogEntryDouble.new '1', Session::OPEN, 'dump', '/path/to/file', nil, '<TIME>'
  end

  describe "open session" do
    before do
      @log_entry.cmd = Session::OPEN
    end
    it "stores the account name" do
      @session.process @log_entry
      @session.account.must_equal 'dump'
    end
    it "opens the session" do
      @session.process @log_entry
      @session.wont_be :closed?
    end
  end

  describe "upload file" do
    before do
      @log_entry.cmd = Session::UPLOAD
    end
    it "stores the uploaded file name" do
      @session.process @log_entry
      @session.uploaded_files.must_equal ['/path/to/file']
    end
    it "stores multiple uploaded files" do
      @session.process @log_entry
      log_entry_2 = @log_entry.dup
      log_entry_2.file = '/path/to/another_file'
      @session.process log_entry_2
      @session.uploaded_files.must_equal ['/path/to/file', '/path/to/another_file']
    end
  end

  describe "close session" do
    before do
      @log_entry.cmd = Session::CLOSE
    end

    it "closes the session" do
      @session.process @log_entry
      @session.must_be :closed?
    end

    it "signals the session manager object to free the object" do
      @session.process @log_entry
      @session_manager.verify
    end

    it "sets the uploaded_at time" do
      @session.process @log_entry
      @session.uploaded_at.must_equal '<TIME>'
    end
  end

  describe "rename file" do
    describe "when file to rename was found" do
      before do
        @log_entry.cmd = Session::UPLOAD
        @session.process @log_entry
        @log_entry.cmd = Session::RENAME
        @log_entry.renamed_to = '/path/to/new-file'
      end

      it "renames the file" do
        @session.uploaded_files.must_include '/path/to/file'
        @session.process @log_entry
        @session.uploaded_files.wont_include '/path/to/file'
        @session.uploaded_files.must_include '/path/to/new-file'
      end
    end

    describe "when file to rename does not exist" do
      before do
        @log_entry.cmd = Session::RENAME
        @log_entry.renamed_to = '/path/to/new-file'
      end
      it "ignores the command" do
        files = @session.uploaded_files
        @session.process @log_entry
        @session.uploaded_files.must_equal files
      end
    end
  end
end

