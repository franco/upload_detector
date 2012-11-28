#!/usr/bin/env ruby
require "rubygems"
require "bundler"
Bundler.setup(:default)
require 'trollop'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'upload_detector'

opts   = CommandlineOptions.new
config = AppConfig.new filename: 'upload_detector.yml', initial_data: opts.opts


log_file = File.open log_file_path
detector = Detector.new log_file: log_file
#detector.add_listener AnnotationListener.new if opts[:annotate]
#detector.add_listener UploadListener.new unless opts[:annotate] || opts[:debug]
detector.add_listener DebugUploadListener.new if opts[:debug]
detector.add_listener ImportTrigger.new

if opts[:log]
  #log_level = opts[:debug] ? Log4r::DEBUG : Log4r::INFO
  log_path = File.join(File.dirname(__FILE__), '..', 'log/import.log')
  @logger = Logger.new(:filename => log_path)
  detector.add_listener @logger
end

forever = opts[:deamonized]
UploadDetector.new( :detector => detector, :logger => logger ).run(forever)

