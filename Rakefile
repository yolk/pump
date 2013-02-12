require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

begin
  require "yard"
  require "yard/rake/yardoc_task"

  namespace :doc do
    desc "Generate Yardoc documentation"
    YARD::Rake::YardocTask.new do |yardoc|
      yardoc.name = "yard"
      yardoc.options = ["--verbose", "--markup", "markdown"]
      yardoc.files = FileList[
        "lib/**/*.rb",
        "-", "README.md", "CHANGES.md", "MIT-LICENSE"
      ]
    end
  end

  task "clobber" => ["doc:clobber_yard"]

  desc "Alias to doc:yard"
  task "doc" => "doc:yard"
rescue LoadError
  # If yard isn't available, it's not the end of the world
  desc "Alias to doc:rdoc"
  task "doc" => "doc:rdoc"
end
