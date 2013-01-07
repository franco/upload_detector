require 'log4r'
require 'active_support/core_ext/string/inflections'
require 'daemons'

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
  attr_reader :logger, :daemonized

  def self.root
    File.expand_path('..',File.dirname(__FILE__))
  end

  def initialize(opts)
    @logger     = opts[:logger] || Log4r::Logger.root # defaults to Null Logger
    @daemonized = opts[:daemonized]
    setup_signal_traps
  end

  def run detector
    run_daemonized if daemonized

    @run = true
    while @run
      detector.detect

      if daemonized
        if @reload
          detector.reload
        else
          sleep 30
        end
      else
        @run = false
      end
    end
  end

  private

  def run_daemonized
    #Daemons.daemonize daemons_options
  end

  def daemons_options
    { ontop: true, app_name: 'upload_detector' }
  end

  def setup_signal_traps
    setup_quit_trap
    setup_usr1_trap
  end

  def setup_usr1_trap
    @reload = false
    trap("USR1") do
      @reload = true
    end
  end

  def setup_quit_trap
    trap("QUIT") do
      @run = false
    end
  end
end

