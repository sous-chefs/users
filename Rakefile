require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:unit)

# We cannot run Test Kitchen on Travis CI yet...
namespace :travis do
  desc 'Run tests on Travis'
  task ci: ['unit']
end

# The default rake task should just run it all
task default: ['travis:ci']
