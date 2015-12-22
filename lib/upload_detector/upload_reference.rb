require 'digest/sha1'

class UploadReference
  attr_accessor :account, :uploaded_at, :files

  def initialize account, uploaded_at, files
    @account, @uploaded_at, @files = account, uploaded_at, files
  end

  def id
    "#{account}-#{uploaded_at.to_i}-#{short_file_digest}"
  end
  def short_file_digest
    file_digest[0,8]
  end
  def file_digest
    Digest::SHA1.hexdigest files.join
  end

  def self.account_from_id id
    match = id.match(/(.*)-\d+-\w{8}$/)
    match && match[1]
  end
end

