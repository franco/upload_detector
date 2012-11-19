class DebugUploadListener
  def on_files_uploaded args
    puts "received files for account '#{args[:account]}' at #{args[:uploaded_at].utc}"
    args[:uploaded_files].each do |file|
      puts "\t#{file}"
    end
  end
end


