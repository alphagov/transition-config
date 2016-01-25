module TransitionConfig
  class RequiredHomepageProtocolException < RuntimeError
    attr_reader :missing
    def initialize(missing)
      @missing = missing
    end

    def to_s
      "Sites missing homepage protocols: \n"\
      "#{@missing.map { |abbr| "#{abbr}.yml" }.join("\n")}"
    end
  end
end
