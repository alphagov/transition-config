#!/usr/bin/env ruby -w

require_relative "mapping_fetcher"

fetcher = MappingFetcher.new
fetcher.remap_new_urls_using(ARGV[0])
puts fetcher.fetch(StringCsvSource.new($stdin).input_csv)
