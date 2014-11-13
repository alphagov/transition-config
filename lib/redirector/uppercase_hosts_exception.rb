module Redirector
  class UppercaseHostsException < RuntimeError
    attr_reader :uppercase
    def initialize(uppercase)
      @uppercase = uppercase
    end

    def to_s
      "Uppercase hosts found: \n"\
      "#{@uppercase.map { |host| "#{host}" }.join("\n")}\n\n"
    end
  end
end
