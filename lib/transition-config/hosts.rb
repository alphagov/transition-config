# frozen_string_literal: true

require "transition-config/duplicate_hosts_exception"
require "transition-config/uppercase_hosts_exception"

module TransitionConfig
  class Hosts
    MASKS = [
      TransitionConfig.path("data/transition-sites/*.yml"),
    ].freeze

    def self.files(masks = MASKS)
      files = Array(masks).inject([]) do |files, mask|
        files.concat(Dir[mask])
      end

      raise "No sites yaml found in #{masks}" if files.empty?

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

    # This is so that the first part of the validates! method can
    # check if there are multiple site abbreviations and
    # therefore duplicates.
    def self.hosts_to_site_abbrs(masks = MASKS)
      # Default entries in the hash to empty array
      # http://stackoverflow.com/a/2552946/3726525
      hosts_to_site_abbrs = Hash.new { |hash, key| hash[key] = Set.new }

      Hosts.all(masks) do |site, host|
        hosts_to_site_abbrs[host] << site.abbr
      end

      hosts_to_site_abbrs
    end

    def self.validate!(masks = MASKS)
      duplicates = {}
      has_uppercase = Set.new
      hosts_to_site_abbrs(masks).each do |host, abbrs|
        duplicates[host] = abbrs if abbrs.size > 1
        has_uppercase << host unless host == host.downcase
      end
      if duplicates.any?
        raise TransitionConfig::DuplicateHostsException, duplicates
      end
      if has_uppercase.any?
        raise TransitionConfig::UppercaseHostsException, has_uppercase
      end
    end
  end
end
