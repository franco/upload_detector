#!/usr/bin/env ruby
require "rubygems"
require "bundler"
Bundler.setup(:default)
require 'trollop'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'upload_detector'

#logger = Logger.new 'UploadDetector'
logger = nil
#logger.outputters = FileOutputter.new('fileOutputter', :filename => 'log')

opts = Trollop::options do
  version "upload_detector 0.1.0 (c) 2012 Shortcut Media AG"
  banner <<-EOS
Checks if new pdfs files got uploaded and are ready to import.

Usage:
       upload_detector [options] <filename>+
where [options] are:
EOS
  opt :annotate, "Dry runs the parser and outputs the logfile with parser annotation. Does not trigger any imports. "
  opt :deamon, "Runs the parser as deamon. "
  opt :debug, "Dry runs the parser and outputs the uploaded files. Does not trigger any imports. "
end

log_file_path = ARGV.shift
log_file = File.open log_file_path


#upload_detector = UploadDetector.new log_file: log_file, log_file_type: 'sftp'
#upload_detector.add_listener AnnotationListener
#upload_detector.start

detector = Detector.new log_file: log_file
detector.add_listener AnnotationListener.new if opts[:annotate]
detector.add_listener UploadListener.new unless opts[:annotate] || opts[:debug]
detector.add_listener DebugUploadListener.new if opts[:debug]
#detector.add_listener ImportTrigger.new

#processor.add_listener LogListener.new

forever = opts[:deamon]
UploadDetector.new( :detector => detector, :logger => logger ).run(forever)

