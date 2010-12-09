require 'rake/testtask'

desc 'Run all tests'
task :default => :test

Rake::TestTask.new do |task|
  task.libs << 'test'
  task.test_files = FileList['test/**/*_test.rb']
  task.verbose = true
  task.warning = true
end

Rake::TestTask.new(:examples) do |task|
  task.test_files = FileList['examples/**/*.rb']
  task.verbose = true
  task.warning = true
end

# Little hack to allow running only tests matching a pattern: NAME=/pattern/
task :process_test_args do
  ENV['TESTOPTS'] = "-n#{ENV['NAME']}" if ENV['NAME']
end

task :test     => :process_test_args
task :examples => :process_test_args
