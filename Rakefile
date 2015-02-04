require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.name = "test"
  t.test_files = FileList['test/test_*.rb']
end

task :default => :test

