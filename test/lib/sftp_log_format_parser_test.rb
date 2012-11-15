$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'


class TestSftpLogFormatParser < MiniTest::Unit::TestCase

  def setup
    @parser = SftpLogFormatParser.new
  end

  def test_parses_session_open
    stmt = "Oct 26 00:24:35 precise64 internal-sftp[10772]: session opened for local user dump from [10.0.2.2]"
    log_entry = @parser.parse stmt
    assert_equal stmt, log_entry.log_stmt
    assert_equal "Oct 26 00:24:35", log_entry.time
    assert_equal "10772", log_entry.session_id
    assert_equal "session opened for local user dump from [10.0.2.2]", log_entry.info
    assert_equal Session::OPEN, log_entry.cmd
    assert_equal "dump", log_entry.account
    assert_nil log_entry.file
  end

  def test_parses_session_closed
    stmt = "Oct 26 00:24:35 precise64 internal-sftp[10772]: session closed for local user dump from [194.209.226.4]"
    log_entry = @parser.parse stmt
    assert_equal stmt, log_entry.log_stmt
    assert_equal "Oct 26 00:24:35", log_entry.time
    assert_equal "10772", log_entry.session_id
    assert_equal "session closed for local user dump from [194.209.226.4]", log_entry.info
    assert_equal Session::CLOSE, log_entry.cmd
    assert_equal "dump", log_entry.account
    assert_nil log_entry.file
  end

  def test_parses_file_closed
    stmt = 'Oct 26 00:24:35 precise64 internal-sftp[10772]: close "/incoming/nzz_003.pdf" bytes read 0 written 304974'
    log_entry = @parser.parse stmt
    assert_equal stmt, log_entry.log_stmt
    assert_equal "Oct 26 00:24:35", log_entry.time
    assert_equal "10772", log_entry.session_id
    assert_equal 'close "/incoming/nzz_003.pdf" bytes read 0 written 304974', log_entry.info
    assert_equal Session::UPLOAD, log_entry.cmd
    assert_nil log_entry.account
    assert_equal "/incoming/nzz_003.pdf", log_entry.file
  end

  def test_parse_file_rename
    stmt = 'Oct 26 00:24:35 kai internal-sftp[10772]: rename old "/incoming/TS_20121108_1.pdf.filepart" new "/incoming/TS_20121108_1.pdf"'
    log_entry = @parser.parse stmt
    assert_equal stmt, log_entry.log_stmt
    assert_equal "Oct 26 00:24:35", log_entry.time
    assert_equal "10772", log_entry.session_id
    assert_equal 'rename old "/incoming/TS_20121108_1.pdf.filepart" new "/incoming/TS_20121108_1.pdf"', log_entry.info
    assert_equal Session::RENAME, log_entry.cmd
    assert_equal "/incoming/TS_20121108_1.pdf.filepart", log_entry.file
    assert_equal "/incoming/TS_20121108_1.pdf", log_entry.renamed_to
  end

  def test_parses_valid_statements
    [
      'Nov  8 00:35:19 kai internal-sftp[3183]: session opened for local user dump from [72.235.51.53]',
      'Nov  8 11:40:04  internal-sftp[7532]: last message repeated 2 times',

    ].each do |stmt|
      assert @parser.parse(stmt)
    end
  end

  def test_parse_with_invalid_stmt
    invalid_stmt = "something wrong 00:24:35 precise64 internal-sftp[10772]: session opened for local user dump from [10.0.2.2]"
    assert_raises(ParserError::InvalidFormatError) do
      @parser.parse invalid_stmt
    end
  end

  def test_parse_with_non_internal_sftp_log_statements
    sshd_log_stmt = "Oct 25 23:09:52 precise64 sshd[8885]: subsystem request for sftp by user dump"
    assert_nil @parser.parse(sshd_log_stmt)
  end

end
