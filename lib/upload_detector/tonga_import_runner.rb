
class TongaImportRunner < ImportRunner

  def initialize args
    super
    @run_script ||= 'sudo -u tonga -H -i /srv/tonga/current/script/local_file_import_runner.sh' # TODO: move into yml?
  end

  protected

    def execute_script import
      identifier = import.upload_reference.account
      shell.execute run_script, [identifier, import.files].flatten
    end

end
