module TransitionConfig
  class RequiredFieldsMissingException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Sites missing required fields: \n"\
      "#{@missing.map { |abbr, fields| "#{abbr}: #{fields}" }.join("\n")}"
    end
  end
end
