require 'yaml'
require 'gds_api/organisations'

module Redirector
  class Site
    MASK                 = File.expand_path('../../../data/sites/*.yml', __FILE__)
    WHITEHALL_PRODUCTION = 'https://whitehall-admin.production.alphagov.co.uk'

    attr_reader :hash
    def initialize(yaml)
      @hash ||= YAML.load(yaml)
    end

    def whitehall_slug
      hash['whitehall_slug']
    end

    def slug_exists_in_whitehall?
      api = GdsApi::Organisations.new(WHITEHALL_PRODUCTION)
      api.organisations.with_subsequent_pages.to_a.any? { |org| org.details.slug == whitehall_slug }
    end

    def self.all
      Dir[MASK].map {|filename| Site.new(File.read(filename))}
    end
  end
end
