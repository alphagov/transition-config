#!/usr/bin/env ruby

require 'csv'

input = CSV.parse($stdin, headers: true).collect { |row|
  [row['Old Url'], (row['New Url'] == "" ? nil : row['New Url']), row['Status']]
}.sort { |a,b| a[0] <=> b[0] }

folded_csv = CSV.generate do |csv|
  csv << ["Old Url", "New Url", "Status"]
  input.each do |row|
    csv << row.map {|x| x.respond_to?(:strip) ? x.strip : nil }
  end
end

puts folded_csv
