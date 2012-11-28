class CommandlineOptions
  attr_reader :opts, :log_file

  def initialize
    parse
  end

  def parse
    @opts = Trollop::options do
      version "upload_detector 0.1.0 (c) 2012 Shortcut Media AG"
      banner <<-EOS
    Checks if new pdfs files got uploaded and are ready to import.

    Usage:
           upload_detector [options] <filename>+
    where [options] are:
    EOS
      opt :annotate, "Dry runs the parser and outputs the logfile with parser annotation. Does not trigger any imports. "
      opt :deamonized, "Runs the parser as deamon. "
      opt :debug, "Dry runs the parser and outputs the uploaded files. Does not trigger any imports. "
      opt :log, "Log to a logfile."
    end

    @log_file = ARGV.shift
    self
  end

  def [](key)
    opts[key]
  end

  def opts
    @opts.merge log_file: log_file
  end
end
