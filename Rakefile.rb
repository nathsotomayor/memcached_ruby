#!/usr/bin/env ruby
require 'rake/testtask'

# Create a task that runs a set of tests
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['tests/*test.rb']
  t.verbose = true
end
