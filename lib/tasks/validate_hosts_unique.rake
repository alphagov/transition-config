require 'redirector/hosts'

desc 'Check that no host appears more than once across all sites, either as host or alias'

task :validate_hosts_unique do
  Redirector::Hosts.validate_uniqueness!
end
