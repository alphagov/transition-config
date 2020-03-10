# frozen_string_literal: true

module TransitionConfig
  class SlugsMissingException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Slugs missing from Whitehall: \n"\
      "#{@missing.map { |abbr, slugs| "#{abbr}: #{slugs}" }.join("\n")}"
    end
  end
end
