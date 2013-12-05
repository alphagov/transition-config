require 'yaml'
require 'htmlentities'
require 'redirector/slugs_missing_exception'

module Redirector
  class Site < Struct.new(:hash)
    MASKS = [
      Redirector.path('data/sites/*.yml'),
      Redirector.path('data/transition-sites/*.yml')
    ]

    NEVER_EXISTED_IN_WHITEHALL = %w(directgov businesslink)

    def abbr
      hash['site']
    end

    def whitehall_slug
      hash['whitehall_slug']
    end

    def title
      Site.coder.decode(hash['title'])
    end

    def host
      hash['host']
    end

    def filename
      File.expand_path("../../data/sites/#{abbr}.yml", File.dirname(__FILE__))
    end

    attr_writer :organisations
    def organisations
      @organisations ||= Organisations.new
    end

    def slug_exists_in_whitehall?
      organisations.by_slug[whitehall_slug]
    end

    def never_existed_in_whitehall?
      NEVER_EXISTED_IN_WHITEHALL.any? do |prefix|
        abbr == prefix || abbr =~ Regexp.new("^#{prefix}_.*$")
      end
    end

    def ordered_output
      {
        'site'             => abbr,
        'whitehall_slug'   => whitehall_slug,
        'title'            => Site.coder.encode(title),
        'redirection_date' => '31st October 2014',
        'homepage'         => "https://www.gov.uk/government/organisations/#{whitehall_slug}",
        'tna_timestamp'    => 20130704203515,
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

    def self.all(masks = MASKS, options = {})
      files = Array(masks).inject([]) do |files, mask|
        files.concat(Dir[mask])
      end

      raise RuntimeError, "No sites yaml found in #{masks}" if files.empty?

      files.map { |filename| Site.from_yaml(filename, options) }
    end

    def self.check_all_slugs!(masks = MASKS)
      missing = Redirector::Site.all(masks, organisations: Organisations.new).reject do |site|
        site.slug_exists_in_whitehall? || site.never_existed_in_whitehall?
      end
      raise Redirector::SlugsMissingException.new(missing) if missing.any?
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

      Site.new({
                 'site'           => abbr,
                 'whitehall_slug' => organisation.details.slug,
                 'title'          => organisation.title,
                 'host'           => host
               })
    end

    def self.coder
      @coder ||= HTMLEntities.new
    end
  end
end
