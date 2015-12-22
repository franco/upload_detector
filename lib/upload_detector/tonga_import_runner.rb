
class TongaImportRunner < ImportRunner

  protected

    def execute_script import
      identifier = import.account
      shell.execute run_script, [identifier, import.files].flatten
    end

end
