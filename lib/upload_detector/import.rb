class Import
  attr_accessor :upload_reference, :files, :error, :run_at

  def initialize args
    @upload_reference = args[:upload_reference]
    @files   = args[:files]
    @error   = args[:error]
    @run_at  = args[:run_at]
  end

  def to_params
    { :upload_reference => upload_reference, :error => error, :files => files, :run_at => run_at }
  end

  def run?
    !@run_at.nil?
  end

  def success?
    run? && error.nil?
  end

  def id
    upload_reference
  end

  def account
    UploadReference.account_from_id id
  end

  def ==(other)
    self.upload_reference == other.upload_reference &&
      self.files == other.files &&
      self.run_at == other.run_at &&
      self.error == other.error
  end
end
