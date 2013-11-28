require 'yaml'
require 'gds_api/organisations'
require 'redirector/slugs_missing_exception'

module Redirector
  class Site < Struct.new(:hash)
    MASK                       = File.expand_path('../../../data/sites/*.yml', __FILE__)
    WHITEHALL_PRODUCTION       = 'https://whitehall-admin.production.alphagov.co.uk'
    NEVER_EXISTED_IN_WHITEHALL = %w(directgov businesslink)

    def abbr
      hash['site']
    end

    def whitehall_slug
      hash['whitehall_slug']
    end

    def title
      hash['title']
    end

    def filename
      File.expand_path("../../data/sites/#{abbr}.yml", File.dirname(__FILE__))
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

    def ordered_output
      {
        'site'             => abbr,
        'whitehall_slug'   => whitehall_slug,
        'title'            => title,
        'redirection_date' => '31st October 2014',
        'tna_timestamp'    => '20130704203515',
        'host'             => "www.#{abbr}.gov.uk",
        'furl'             => "www.gov.uk/#{abbr}",
        'aliases'          => %W(www1.#{abbr}.gov.uk www2.#{abbr}.gov.uk)
      }
    end

    def save!
      File.open(filename, 'w') { |file| ordered_output.to_yaml(file) }
    end

    def to_s
      "#{abbr}: #{whitehall_slug}"
    end

    def self.organisations_api
      @organisations_api ||= GdsApi::Organisations.new(WHITEHALL_PRODUCTION)
    end

    def self.get_organisations
      organisations_api.organisations.with_subsequent_pages.to_a
    end

    def self.all(mask = MASK)
      mask  = File.expand_path(mask)
      files = Dir[mask]
      raise RuntimeError, "No sites yaml found in #{mask}" if files.empty?

      organisations = Site.get_organisations
      files.map do |filename|
        Site.new(YAML.load(File.read(filename))).tap { |s| s.whitehall_orgs = organisations }
      end
    end

    def self.check_all_slugs!(mask = MASK)
      missing = Redirector::Site.all(mask).reject do |site|
        site.slug_exists_in_whitehall? || site.never_existed_in_whitehall?
      end
      raise Redirector::SlugsMissingException.new(missing) if missing.any?
    end

    def self.from_yaml(filename)
      Site.new(YAML.load(File.read(filename)))
    end

    def self.create(abbr, whitehall_slug)
      response = organisations_api.organisation(whitehall_slug)
      raise ArgumentError,
            "No organisation with whitehall_slug #{whitehall_slug} found. "\
            'Not creating site.' unless response

      organisation = response.to_ostruct
      Site.new({
                 'site'           => abbr,
                 'whitehall_slug' => organisation.details.slug,
                 'title'          => organisation.title
               })
    end
  end
end
