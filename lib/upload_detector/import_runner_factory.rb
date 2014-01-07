class ImportRunnerFactory
  def self.build config
    runner_class = config[:runner]
    runner_class.constantize.new config
  end
end

