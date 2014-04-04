require 'yaml'
require 'htmlentities'
require 'redirector/slugs_missing_exception'
require 'redirector/tna_timestamp'

module Redirector
  class Site
    MASKS = [
      Redirector.path('data/sites/*.yml'),
      Redirector.path('data/transition-sites/*.yml')
    ]

    PATHS = {
      :bouncer    => 'transition-sites',
      :redirector => 'sites'
    }

    NEVER_EXISTED_IN_WHITEHALL = %w(directgov businesslink)

    attr_accessor :hash
    def initialize(hash, options = { type: :bouncer })
      @options = options
      PATHS[type] || (raise ArgumentError, "Unknown type #{type}")

      self.hash = hash
    end

    def type
      @options[:type]
    end

    def sites_path
      PATHS[type]
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

    def title
      Site.coder.decode(hash['title'])
    end

    def host
      hash['host']
    end

    def tna_timestamp
      if timestamp = Redirector::TNATimestamp.new(host).find
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
        'title'            => Site.coder.encode(title),
        'redirection_date' => '31st October 2014',
        'homepage'         => "https://www.gov.uk/government/organisations/#{whitehall_slug}",
        'tna_timestamp'    => tna_timestamp,
        'host'             => host,
        'furl'             => "www.gov.uk/#{abbr}",
        'aliases'          => %W(www1.#{host} www2.#{host}),
        'global'           => "=301 https://www.gov.uk/government/organisations/#{whitehall_slug}",
        'options'          => "--query-string qstring1:qstring2:qstring3"
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
      missing = Redirector::Site.all(masks, organisations: Organisations.new).reject do |site|
        site.slug_exists_in_whitehall?(site.whitehall_slug) || site.never_existed_in_whitehall?
      end
      raise Redirector::SlugsMissingException.new(missing) if missing.any?
    end

    def self.from_yaml(filename, options = {})
      Site.new(YAML.load(File.read(filename))).tap do |site|
        site.organisations = options[:organisations]
      end
    end

    def self.create(abbr, whitehall_slug, host, options = { type: :bouncer })
      organisation = Organisations.new.find(whitehall_slug)
      raise ArgumentError,
            "No organisation with whitehall_slug #{whitehall_slug} found. "\
            'Not creating site.' unless organisation

      Site.new(
        {
          'site'           => abbr,
          'whitehall_slug' => organisation.details.slug,
          'title'          => organisation.title,
          'host'           => host
        },
        options
      )
    end

    def self.coder
      @coder ||= HTMLEntities.new
    end
  end
end
