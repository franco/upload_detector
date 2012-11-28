class Logger
  attr_reader :logger

  def initialize args={}
    @logger = args[:logger] || initialize_logger(args)
  end

  # callbacks
  def on_files_uploaded args
    logger.info "#{args[:uploaded_at].utc} received files for account '#{args[:account]}'"
    args[:uploaded_files].each do |file|
      logger.info "\t#{file}"
    end
  end

  def on_process_line args
    logger.debug{ "Processing next log statement: '#{args[:line]}'" }
  end

  def on_invalid_line args
    logger.debug{ "Log statement does not match expected format: '#{args[:line]}'" }
  end

  def on_ignore_line line
    logger.debug{ "Log statement ignored: '#{args[:line]}'" }
  end

  private

  def initialize_logger args
    require 'log4r'
    filename = args[:filename] || 'import.log'
    file = Log4r::FileOutputter.new('fileOutputter', :filename => filename,:trunc => false)
    logger = Log4r::Logger.new 'UploadDetectorLog'
    logger.level = args[:level] || Log4r::INFO
    logger.add file
    #logger.outputters = Outputter.stdout

    logger
  end
end


