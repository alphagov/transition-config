#!/usr/bin/env ruby

require_relative "../munge/mapping_fetcher"

CSV do |csv|
  headers = ['Old Url', 'New Url', 'Status']
  csv << headers
  input = StringCsvSource.new($stdin).input_csv
  input = MappingFetcher.new.follow_url_chains(input)
  input.each do |line|
    csv << headers.map {|header| line[header.downcase] }
  end
end
