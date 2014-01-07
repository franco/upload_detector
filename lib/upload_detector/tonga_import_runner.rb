
class TongaImportRunner < ImportRunner

  protected

    def execute_script import
      identifier = import.upload_reference.account
      shell.execute run_script, [identifier, import.files].flatten
    end

end
