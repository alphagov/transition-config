require 'redirector'

desc 'Check that no host appears uppercase or more than once across all sites, either as host or alias'
namespace :hosts do
  task :validate do
    Redirector::Hosts.validate!
  end
end
