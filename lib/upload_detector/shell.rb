# copied from ruby tapas episode 017

CommandResult = Struct.new :status, :output

class Shell
  def execute command, flags=[], input=nil
    result = CommandResult.new
    IO.popen([command, *flags], 'w+', err: [:child, :out]) do |io|
      io.write(input) if input
      io.close_write
      result.output = io.read
    end
    result.status = $?
    result
  end
end
