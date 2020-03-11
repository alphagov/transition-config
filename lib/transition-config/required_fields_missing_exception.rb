# frozen_string_literal: true

module TransitionConfig
  class RequiredFieldsMissingException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Sites missing required fields: \n"\
      "#{@missing.map { |filename, fields| "#{filename}.yml: #{fields}" }.join("\n")}"
    end
  end
end
