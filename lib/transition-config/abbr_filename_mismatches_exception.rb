# frozen_string_literal: true

module TransitionConfig
  class AbbrFilenameMismatchesException < RuntimeError
    attr_reader :mismatches
    def initialize(mismatches)
      @mismatches = mismatches
    end

    def to_s
      "Some site abbrs don't match their filenames: \n"\
      "#{@mismatches.map { |filename, abbr| "Filename #{filename}.yml, abbr #{abbr}" }.join("\n")}\n\n"
    end
  end
end
