require 'redirector/duplicate_hosts_exception'

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

    def self.hosts_to_site_abbrs(masks = MASKS)
      # Default entries in the hash to empty array
      # http://stackoverflow.com/a/2552946/3726525
      hosts_to_site_abbrs = Hash.new { |hash, key| hash[key] = [] }

      files(masks).each do |filename|
        site = Site.from_yaml(filename)
        site.all_hosts.each do |host|
          hosts_to_site_abbrs[host] << site.abbr
        end
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
  end
end
