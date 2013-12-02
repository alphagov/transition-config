module Redirector
  class SlugsMissingException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Slugs missing from Whitehall: \n"\
      "#{@missing.map {|site| "#{site.abbr}: #{site.whitehall_slug || 'N/A'}"}.join("\n")}"
    end
  end
end
