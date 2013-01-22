#!/usr/bin/env ruby

require 'csv'

abort "Usage: #{__FILE__} http://example.com < document_mappings.csv" unless ARGV.size > 0

input = CSV.parse($stdin, headers: true).select { |row|
  /#{Regexp.escape(ARGV.first)}/ =~ row['Old Url']
}.collect { |row|
  [row['Old Url'], row['New Url']]
}

out = CSV.generate do |csv|
  csv << ["Old Url", "New Url"]
  input.each do |row|
    csv << row
  end
end

puts out
