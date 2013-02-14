#!/usr/bin/env ruby

require 'csv'

abort "Usage: #{__FILE__} http://example.com < document_mappings.csv" unless ARGV.size > 0

def include_row?(row)
  ['published', 'draft', 'submitted', 'Closed'].include?(row['State'])
end

input = CSV.parse($stdin, headers: true).select { |row|
  /#{Regexp.escape(ARGV.first)}/ =~ row['Old Url']
}.collect { |row|
  [row['Old Url'], row['New Url'], row['Status']] if include_row? row
}

out = CSV.generate do |csv|
  csv << ["Old Url", "New Url", "Status"]
  input.each do |row|
    next if row.nil?
    csv << row
  end
end

puts out
