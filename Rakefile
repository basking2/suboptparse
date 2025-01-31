# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rdoc/task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
  rdoc.options << "--format=darkfish"
  rdoc.title = "SubOptParse"
  rdoc.rdoc_dir = "rdoc"
end

task default: %i[spec rubocop]
