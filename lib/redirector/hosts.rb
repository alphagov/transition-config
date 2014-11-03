require 'redirector/duplicate_hosts_exception'
require 'redirector/uppercase_hosts_exception'

module Redirector
  class Hosts
    MASKS = [
      Redirector.path('data/transition-sites/*.yml')
    ]

    def self.files(masks = MASKS)
      files = Array(masks).inject([]) do |files, mask|
        files.concat(Dir[mask])
      end

      raise RuntimeError, "No sites yaml found in #{masks}" if files.empty?

      files
    end

    # This method iterates all the hosts for a specified site
    # according to its YAML.
    def self.all(masks = MASKS)
      files(masks).each do |filename|
        site = Site.from_yaml(filename)
        site.all_hosts.each do |host|
          yield site, host
        end
      end
    end

    # This is so that the first part of the validates_unique_and_lowercase!
    # method can check if there are multiple site abbreviations and
    # therefore duplicates.
    def self.hosts_to_site_abbrs(masks = MASKS)
      # Default entries in the hash to empty array
      # http://stackoverflow.com/a/2552946/3726525
      hosts_to_site_abbrs = Hash.new { |hash, key| hash[key] = [] }

      Hosts.all(masks) do |site, host|
        hosts_to_site_abbrs[host] << site.abbr
      end

      hosts_to_site_abbrs
    end

    def self.validate_uniqueness!(masks = MASKS)
      duplicates = {}
      hosts_to_site_abbrs(masks).each do |host, abbrs|
        duplicates[host] = abbrs if abbrs.size > 1
      end
      raise Redirector::DuplicateHostsException.new(duplicates) unless duplicates.empty?
    end

    def self.validate_lowercase!(masks = MASKS)
      uppercase = {}
      Hosts.all(masks) do |_, host|
        uppercase[host] = host unless host == host.downcase
      end
      raise Redirector::UppercaseHostsException.new(uppercase) unless uppercase.empty?
    end
  end
end
