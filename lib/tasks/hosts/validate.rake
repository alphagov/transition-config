require 'transition-config'

desc 'Check that no host appears uppercase or more than once across all sites, either as host or alias'
namespace :hosts do
  task :validate do
    TransitionConfig::Hosts.validate!
  end
end
