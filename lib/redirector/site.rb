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

    def whitehall_orgs
      api = GdsApi::Organisations.new(WHITEHALL_PRODUCTION)
      api.organisations.with_subsequent_pages.to_a
    end

    def to_s
      "#{abbr}: #{whitehall_slug}"
    end

    def self.all(mask = MASK)
      mask  = File.expand_path(mask)
      files = Dir[mask]
      raise RuntimeError, "No sites yaml found in #{mask}" if files.empty?

      files.map { |filename| Site.new(File.read(filename)) }
    end

    def self.check_all_slugs!(mask = MASK)
      missing = Redirector::Site.all(mask).reject do |site|
        site.slug_exists_in_whitehall? || site.never_existed_in_whitehall?
      end
      raise Redirector::SlugsMissingException.new(missing) if missing.any?
    end
  end
end
