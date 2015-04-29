module TransitionConfig
  class OrganisationContentIDsMissingException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Organisation content_ids not found in Whitehall: \n"\
      "#{@missing.map { |abbr, content_ids| "#{abbr}: content IDs: #{content_ids}" }.join("\n")}"
    end
  end
end
