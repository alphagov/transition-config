# frozen_string_literal: true

require "yaml"
require "gds_api/organisations"

module TransitionConfig
  class Organisations
    ORGANISATIONS_API_HOST = "https://www.gov.uk"

    def organisations_api
      @organisations_api ||= GdsApi::Organisations.new(ORGANISATIONS_API_HOST)
    end

    def all
      @all ||= organisations_api.organisations.with_subsequent_pages.to_a
    end

    ##
    # Find a single org, get its OpenStruct
    def find(slug)
      organisations_api.organisation(slug)
    end

    ##
    # A hash of orgs by slug. Intended for use in a batch process
    # where we want to ask the server once for all orgs, then not again
    def by_slug
      @by_slug ||= all.each_with_object({}) do |org, orgs|
        orgs[org.details.slug] = org
      end
    end
  end
end
