#!/usr/bin/env ruby -w

base_dir = File.expand_path("..", File.dirname(__FILE__))
missing_mappings_url = "https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=0&output=csv"

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("decc")

# Note if there are duplicates then the FIRST mapping is used, so order matters here
fetcher.add_source(MappingFetcher::RemoteCsvSource.new(missing_mappings_url))

# download this from https://whitehall-admin.production.alphagov.co.uk/government/document_mappings.csv
fetcher.remap_new_urls_using(base_dir + "/document_mappings.csv")
fetcher.fetch
