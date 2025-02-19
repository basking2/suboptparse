# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rdoc/task"
require "English"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "CHANGELOG.md", "lib/**/*.rb")
  rdoc.options << "--format=darkfish"
  rdoc.title = "SubOptParse"
  rdoc.rdoc_dir = "rdoc"
end

task :version, [:val] do |_t, args|
  raise StandardError.new, "Version must be formatted as v[digit].[digit].[digit]." \
      unless args[:val] =~ /^v([0-9]+\.[0-9]+\.[0-9]+)$/

  ver = $LAST_MATCH_INFO[1]
  puts ver
  vfile = [
    "# frozen_string_literal: true",
    "",
    "module SubOptParse",
    "  VERSION = \"#{ver}\"",
    "end",
    ""
  ].join("\n")
  File.open("./lib/suboptparse/version.rb", "wt") do |io|
    io.write(vfile)
  end
end

task default: %i[spec rubocop]
