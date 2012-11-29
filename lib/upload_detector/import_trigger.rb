UploadReference = Struct.new(:account, :uploaded_at) do
  def id
    "#{account}-#{uploaded_at.to_i}"
  end
end

# TODO: make it run in parallel later with celluloid
class ImportTrigger
  attr_reader :import_store, :import_runner
  def initialize args={}
    @import_store  = args[:store] || ImportStore.new(location: args[:pstore_file])
    @import_runner = args[:import_runner] || ImportRunner.new(args)
  end

  def trigger_import
    import = import_store.find_or_create_import( import_attrs )

    unless import.run?
      import_runner.run import

      if import.success?
        import.save
      end
    else
      # Import did already run. Do nothing.
    end
  end

  # callbacks
  def on_files_uploaded args
    @account        = args[:account]
    @uploaded_at    = args[:uploaded_at]
    @uploaded_files = args[:uploaded_files]
    trigger_import
  end


  def upload_reference
    UploadReference.new(@account, @uploaded_at).id
  end

  def import_attrs
    { :upload_reference => upload_reference, :files => @uploaded_files }
  end

  #def find_or_create_import
    #if import_data = @store[upload_reference]
      #import = Import.new import_data
    #else
      #import = Import.new(upload_reference: upload_reference, files: @uploaded_files)
      #@store[upload_reference] = import.to_params
    #end
    #import
  #end

end


