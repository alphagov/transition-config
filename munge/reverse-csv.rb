#!/usr/bin/env ruby

require 'csv'

input = CSV.parse($stdin).to_a

CSV do |csv|
  csv << input.shift
  input.reverse.each do |line|
    csv << line
  end
end
