class LogFile
  attr_reader :path

  def initialize path
    @path = path
  end

  # auto open file and reopen it in case of filename change (usually caused by log rotation)
  def each *args, &block
    file.each(*args, &block)

    if moved?
      @moved = false
      @file_io = nil
      self.each(*args, &block)
    end
  end

  def file
    @file_io ||= File.open path
  end

  def moved?
    @moved = false unless defined? @moved
    @moved
  end

  def moved
    @moved = true
  end
end


#class LogFile < File

  #def changed?
    #@changed = false unless defined? @changed
    #@changed
  #end

  #def has_changed

    #@changed
  #end


  #def reopen_file
    #if changed?
      #close if open?



    #end

  #end

  ## ensures that the file is reopend if file changed
  #def each *args, &block
    #reopen_file
    #super
  #end
#end
