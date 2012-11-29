require 'timeout'
# Currently the Upload Detector module does not now anything about the
# backend and has no idea which account has which import specifications.
# The runner script in the backend has to find out by itself which
# import specification to run.
class ImportRunner
  TimeoutError = Timeout::Error

  attr_accessor :timeout, :shell, :run_script

  attr_accessor :state, :error, :result

  def initialize args={}
    @timeout    = args[:timeout] || 10*60 # defaults to 10 minutes
    @shell      = args[:shell] || Shell.new
    @run_script = args[:run_script]
    @state      = :init
  end

  def self.test_run files=nil
    files ||= ["/srv/sftp/20minuten/incoming/20MIN_ZH_20121121_038.pdf"]
    import = Import.new(files: files)
    import_config = AppConfig.new filename: 'import_trigger.yml', env: env
    ImportRunner.new(import_config).run(import)
  end

  def run import
    raise RuntimeError "Can not run twice." if state != :init
    return self if import.run?

    self.state  = :run
    self.result = nil
    Timeout::timeout timeout, TimeoutError do
      self.result = shell.execute "#{run_script}", import.files
    end

    if result.status.success?
      import.run_at Time.now
      self.state = :imported
    end

  rescue Timeout::Error
    self.state = :error
    self.error = :timeout
    import.error = error
  rescue Exception => e
    self.state = :error
    self.error = e.message
    import.error = e.message
  ensure
    self
  end

  def imported_files
    # we don't know for sure as the import doesn't return enough
    # information yet. We just get success or not.
  end

end

