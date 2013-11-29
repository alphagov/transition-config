require 'yaml'
require 'redirector/slugs_missing_exception'

module Redirector
  class Site < Struct.new(:hash)
    MASK                       = File.expand_path('../../../data/sites/*.yml', __FILE__)
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
        'title'            => title,
        'redirection_date' => '31st October 2014',
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

    def self.all(mask = MASK, options = {})
      mask  = File.expand_path(mask)
      files = Dir[mask]
      raise RuntimeError, "No sites yaml found in #{mask}" if files.empty?

      files.map { |filename| Site.from_yaml(filename, options) }
    end

    def self.check_all_slugs!(mask = MASK)
      missing = Redirector::Site.all(mask, organisations: Organisations.new).reject do |site|
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
  end
end
