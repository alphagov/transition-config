#!/usr/bin/env ruby

require 'csv'

abort "Usage: #{__FILE__} http://example.com < document_mappings.csv" unless ARGV.size > 0

input = CSV.parse($stdin, headers: true).select { |row|
  /#{Regexp.escape(ARGV.first)}/ =~ row['Old Url']
}.collect { |row|
  [row['Old Url'], row['New Url']] if ['published','draft','submitted'].include?(row['State'])
}

out = CSV.generate do |csv|
  csv << ["Old Url", "New Url"]
  input.each do |row|
    next if row.nil?
    csv << row
  end
end

puts out
