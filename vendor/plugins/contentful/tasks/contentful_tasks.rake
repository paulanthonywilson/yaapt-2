require File.dirname(__FILE__) + '/contentful_task_helper.rb'

ns = namespace :contentful do
  desc "Show diffs between changed and expected test output"
  task :diff do
    Contentful::TaskHelper.diff(Rake.original_dir)
  end

  desc "Accept changes to test output"
  task :accept do
    Contentful::TaskHelper.accept(Rake.original_dir)
  end

  desc "Run tests that check contentful output"
  task :test => "db:test:prepare" do
    Contentful::TaskHelper.test(Rake.original_dir)
  end
end

namespace :test do
  desc "Alias for contentful:diff"
  task :diff => ns[:diff]

  desc "Alias for contentful:accept"
  task :accept => ns[:accept]

  desc "Alias for contentful:test"
  task :content => ns[:test]
end

task :contentful => ns[:diff]
