require 'optparse'

class CommandlineOptions
  attr_reader :opts, :input_files

  def initialize
    parse
  end

  def parse

    @opts = options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: (UPLOAD_DETECTOR_ENV=<ENV>) upload_detector [options] (<filename>+)"
      opts.version = "0.1.0 (c) 2012 Shortcut Media AG"

      opts.on("-a", "--[no-]annotate", "Run with internal parser annotations") do |a|
        options[:annotate] = a
      end

      opts.on("-d", "--[no-]daemonize", "Run as daemon") do |d|
        options[:daemonize] = d
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:debug] = v
      end

      opts.on("-l", "--log [logfile]", "Enable logging") do |log|
        if log
          options[:logfile] = log
        else
          puts "You must provide a logfile. See help for more information."
          exit
        end
      end

      opts.on("-i", "--input[logfile]", "Input file to parse") do |input|
        if input
          options[:input_file] = input
        else
          puts "You must provide a file. See help for more information."
          exit
        end
      end

      opts.on("--no-import", "Do not trigger an import") do |no_import|
        options[:no_import] = true
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end.parse!

    #@log_file = ARGV.shift

    self
  end

  def [](key)
    opts[key]
  end

end
