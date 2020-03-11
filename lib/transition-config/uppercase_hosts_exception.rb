# frozen_string_literal: true

module TransitionConfig
  class UppercaseHostsException < RuntimeError
    attr_reader :uppercase
    def initialize(uppercase)
      @uppercase = uppercase
    end

    def to_s
      "Uppercase hosts found: \n"\
      "#{@uppercase.map(&:to_s).join("\n")}\n\n"
    end
  end
end
