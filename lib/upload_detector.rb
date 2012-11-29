require 'log4r'
require 'active_support/core_ext/string/inflections'

module Loggable
  include Log4r
  def logger identifier='UploadDetectorLog'
    @logger ||= Logger.root # Logger[identifier]
  end
  private :logger
end

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'upload_detector')
Dir[File.dirname(__FILE__) + '/upload_detector/*.rb'].each do |file|
  basename = File.basename(file, File.extname(file))
  require basename
  basename.classify.constantize.send :include, Loggable
end


class UploadDetector
  attr_reader :detector, :logger

  def self.root
    File.expand_path('..',File.dirname(__FILE__))
  end

  def initialize(args)
    @detector = args[:detector]
    @logger = args[:logger] || Log4r::Logger.root # defaults to Null Logger
  end

  def run forever=true
    run = true
    while run
      detector.detect
      run = forever
    end
  end
end

