require 'redirector/hosts'

desc 'Check that no host appears uppercase or more than once across all sites, either as host or alias'

task :validate_hosts_unique_and_lowercase do
  Redirector::Hosts.validate_unique_and_lowercase!
end
