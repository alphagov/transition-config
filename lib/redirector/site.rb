require 'yaml'
require 'gds_api/organisations'
require 'redirector/slugs_missing_exception'

module Redirector
  class Site
    MASK                       = File.expand_path('../../../data/sites/*.yml', __FILE__)
    WHITEHALL_PRODUCTION       = 'https://whitehall-admin.production.alphagov.co.uk'
    NEVER_EXISTED_IN_WHITEHALL = %w(directgov businesslink)

    attr_reader :hash

    def initialize(yaml)
      @hash ||= YAML.load(yaml)
    end

    def abbr
      hash['site']
    end

    def whitehall_slug
      hash['whitehall_slug']
    end

    def slug_exists_in_whitehall?
      whitehall_orgs.any? { |org| org.details.slug == whitehall_slug }
    end

    def never_existed_in_whitehall?
      NEVER_EXISTED_IN_WHITEHALL.any? do |prefix|
        abbr == prefix || abbr =~ Regexp.new("^#{prefix}_.*$")
      end
    end

    attr_writer :whitehall_orgs
    def whitehall_orgs
      @whitehall_orgs ||= self.get_organisations
    end

    def to_s
      "#{abbr}: #{whitehall_slug}"
    end

    def self.get_organisations
      api = GdsApi::Organisations.new(WHITEHALL_PRODUCTION)
      api.organisations.with_subsequent_pages.to_a
    end

    def self.all(mask = MASK)
      mask  = File.expand_path(mask)
      files = Dir[mask]
      raise RuntimeError, "No sites yaml found in #{mask}" if files.empty?

      organisations = Site.get_organisations
      files.map do |filename|
        Site.new(File.read(filename)).tap {|s| s.whitehall_orgs = organisations}
      end
    end

    def self.check_all_slugs!(mask = MASK)
      missing = Redirector::Site.all(mask).reject do |site|
        site.slug_exists_in_whitehall? || site.never_existed_in_whitehall?
      end
      raise Redirector::SlugsMissingException.new(missing) if missing.any?
    end
  end
end
