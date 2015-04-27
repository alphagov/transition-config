module TransitionConfig
  class OrganisationContentIDsMissingException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Organisation content_ids missing from Whitehall: \n"\
      "#{@missing.map { |abbr, content_ids| "#{abbr}: #{content_ids}" }.join("\n")}"
    end
  end
end
