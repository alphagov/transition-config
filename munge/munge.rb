#!/usr/bin/env ruby

require_relative "mapping_fetcher"

fetcher = MappingFetcher.new
fetcher.remap_new_urls_using(ARGV[0])
puts fetcher.munge(StringCsvSource.new($stdin).input_csv)
