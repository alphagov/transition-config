require 'yaml'
require 'transition-config/slugs_missing_exception'
require 'transition-config/tna_timestamp'

module TransitionConfig
  class Site
    MASKS = [
      TransitionConfig.path('data/transition-sites/*.yml')
    ]

    NEVER_EXISTED_IN_WHITEHALL = %w(directgov businesslink)

    attr_accessor :hash
    def initialize(hash)
      self.hash = hash
    end

    def sites_path
      'transition-sites'
    end

    def abbr
      hash['site']
    end

    def whitehall_slug
      hash['whitehall_slug']
    end

    def extra_organisation_slugs
      hash['extra_organisation_slugs']
    end

    def host
      hash['host']
    end

    def aliases
      hash['aliases'] || []
    end

    def all_hosts
      [host] + aliases
    end

    def tna_timestamp
      if timestamp = TransitionConfig::TNATimestamp.new(host).find
        timestamp.to_i
      else
        nil
      end
    end

    def filename
      File.expand_path("../../data/#{sites_path}/#{abbr}.yml", File.dirname(__FILE__))
    end

    attr_writer :organisations
    def organisations
      @organisations ||= Organisations.new
    end

    def slug_exists_in_whitehall?(slug)
      organisations.by_slug[slug]
    end

    def never_existed_in_whitehall?
      NEVER_EXISTED_IN_WHITEHALL.any? do |prefix|
        abbr == prefix || abbr =~ Regexp.new("^#{prefix}_.*$")
      end
    end

    def all_slugs
      [].tap do |all_slugs|
        all_slugs.push(whitehall_slug) unless never_existed_in_whitehall?
        all_slugs.concat(extra_organisation_slugs) if extra_organisation_slugs
      end
    end

    def missing_slugs
      all_slugs.reject { |slug| slug_exists_in_whitehall?(slug) }
    end

    def ordered_output
      {
        'site'             => abbr,
        'whitehall_slug'   => whitehall_slug,
        'homepage'         => "https://www.gov.uk/government/organisations/#{whitehall_slug}",
        'tna_timestamp'    => tna_timestamp,
        'host'             => host,
      }
    end

    def save!
      File.open(filename, 'w') { |file| ordered_output.to_yaml(file) }
    end

    def to_s
      "#{abbr}: #{whitehall_slug}"
    end

    def self.all(masks = MASKS, options = {})
      files = Array(masks).inject([]) do |files, mask|
        files.concat(Dir[mask])
      end

      raise RuntimeError, "No sites yaml found in #{masks}" if files.empty?

      files.map { |filename| Site.from_yaml(filename, options) }
    end

    def self.check_all_slugs!(masks = MASKS)
      missing = {}
      TransitionConfig::Site.all(masks, organisations: Organisations.new).each do |site|
        unless site.missing_slugs.empty?
          missing[site.abbr] = site.missing_slugs
        end
      end
      raise TransitionConfig::SlugsMissingException.new(missing) unless missing.empty?
    end

    def self.from_yaml(filename, options = {})
      Site.new(YAML.load(File.read(filename))).tap do |site|
        site.organisations = options[:organisations]
      end
    end

    def self.create(abbr, whitehall_slug, host)
      organisation = Organisations.new.find(whitehall_slug)
      raise ArgumentError,
            "No organisation with whitehall_slug #{whitehall_slug} found. "\
            'Not creating site.' unless organisation

      Site.new(
        {
          'site'           => abbr,
          'whitehall_slug' => organisation.details.slug,
          'host'           => host
        }
      )
    end
  end
end
