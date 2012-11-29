$LOAD_PATH << File.join(File.dirname(__FILE__), '..' )
require  'test_helper.rb'

class ShellDouble
  def initialize result
    @result = result
  end
  def execute *args
    @result
  end
end

class ResultDouble
  attr_accessor :state, :success
  alias :success? :success
end

class ImportDouble
  attr_accessor :files, :run_at, :error

  def run?
    false
  end
end

describe ImportRunner do
  before do
    @result = ResultDouble.new
    @shell = ShellDouble.new(@result)
    @import = ImportDouble.new
    @runner = ImportRunner.new shell: @shell, run_script: '<command>'
  end

  describe "when successful" do
    before do
      @result.success = true
    end
    it "sets the run_at time" do
      now = Time.now
      Time.stub :now, now do
        @runner.run @import
        @import.run_at.must_equal now
      end
    end
  end
end

