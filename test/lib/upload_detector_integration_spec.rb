require  'test_helper.rb'
$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )

class ImportRunnerDouble
  attr_reader :run_imports
  def initialize
    @run_imports = []
  end

  def run import
    @run_imports << import
    import.run_at = Time.now
  end
end

describe "integration test" do
  before do
    @store_file = File.join(File.dirname(__FILE__), '../../tmp', 'test.pstore' )
    File.delete @store_file if File.exists?(@store_file)
    @store = ImportStore.new location: @store_file
    @import_runner = ImportRunnerDouble.new
  end

  after do
    File.delete @store_file if File.exists?(@store_file)
  end

  it "handles multpile concurrent sessions at the same time (ess session)" do
    # ESS 20130320
    # Imported pages were: 3, 4, 6, 9, 10, 12, 14, 16, 19, 20, 21, 22, 24, 25, 26, 27
    # expected were : 1 - 28

    upload_listener = ImportTrigger.new store: @store, import_runner: @import_runner, root_import_path: ''

    input_file = Fixture.load 'ess_session.log'

    detector = Detector.new input_file: input_file, log_format: 'sftp'
    detector.add_listener upload_listener

    UploadDetector.new( daemonized: false ).run(detector)
    @import_runner.run_imports.map(&:files).flatten.sort.must_equal (
      (1..28).to_a.map{ |i| "/ess/incoming/ESBR_20130320_%03d.pdf" % i } )
  end
end
