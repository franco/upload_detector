#!/usr/bin/env ruby

#load environment
env = ENV['UPLOAD_DETECTOR_ENV'] || 'development'
require "rubygems"
require "bundler"
Bundler.setup(:default, env)

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'upload_detector'

opts   = CommandlineOptions.new
config = AppConfig.new filename: 'upload_detector.yml', env: env, initial_data: opts.opts

# Daemonize process if needed
#
# This will change the current directory[1].
# [1] http://stackoverflow.com/questions/11237815/ruby-cant-write-to-logs-in-daemons
if config.daemonize
  daemons_options = { ontop: true, app_name: 'upload_detector', dir_mode: :normal, dir: config.pidfile }
  Daemons.daemonize daemons_options
end


input_file = File.open File.expand_path(config.input_file, UploadDetector.root)
#input_file = File.expand_path(config.input_file, UploadDetector.root)
detector = Detector.new input_file: input_file

#detector.add_listener AnnotationListener.new if opts[:annotate]
#detector.add_listener UploadListener.new unless opts[:annotate] || opts[:debug]
detector.add_listener DebugUploadListener.new if opts[:debug]

if config.logfile
  #log_level = opts[:debug] ? Log4r::DEBUG : Log4r::INFO
  log_path = File.expand_path(config.logfile, UploadDetector.root)
  logger = Logger.new(:filename => log_path)
  detector.add_listener logger
end

unless opts[:no_import]
  import_config = AppConfig.new filename: 'import_trigger.yml', env: env
  detector.add_listener ImportTrigger.new(import_config)
end

UploadDetector.new( logger: nil, daemonized: config.daemonize ).run( detector )

