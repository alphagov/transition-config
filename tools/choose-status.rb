#!/usr/bin/env ruby

require_relative "../munge/mapping_fetcher"

def blank?(url)
  url.nil? || url.strip.empty?
end

def transform(rows)
  Enumerator.new do |yielder|
    rows.each do |row|
      yielder << yield(row)
    end
  end
end

CSV do |csv|
  headers = ['Old Url', 'New Url', 'Status']
  csv << headers
  input = StringCsvSource.new($stdin).input_csv
  input = transform(input) do |row|
    if row['status'] != '418'
      row['status'] = blank?(row['new url']) ? "410" : "301"
    end
    row
  end
  input.each do |line|
    csv << headers.map {|header| line[header.downcase] }
  end
end
