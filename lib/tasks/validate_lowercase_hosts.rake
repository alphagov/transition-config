require 'redirector/hosts'

desc 'Check that no host has uppercase characters in it'

task :validate_lowercase_hosts do
  Redirector::Hosts.validate_lowercase!
end
