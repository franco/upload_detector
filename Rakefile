require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  #t.libs << "test"
  #t.libs = ["lib"]
  #t.warning = true
  #t.verbose = true
  #t.pattern = "test/*_spec.rb"
  t.test_files = FileList['test/lib/*_spec.rb', 'test/lib/*_test.rb']
end

