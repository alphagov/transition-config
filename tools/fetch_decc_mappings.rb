#!/usr/bin/env ruby -w

base_dir = File.expand_path("..", File.dirname(__FILE__))

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("decc")

# Note if there are duplicates then the FIRST mapping is used, so order matters here
{
  harvester: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=3&output=csv',
  furls: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=6&output=csv',
  manual: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=0&output=csv',
  analytics: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=4&output=csv',
  sitemap: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=8&output=csv',
  other: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdDF4SGR6TTBVd0Q1M2dlbmxZTWpSeFE&single=true&gid=10&output=csv'
}.each do |_, url|
  fetcher.add_source(MappingFetcher::RemoteCsvSource.new(url))
end

# download this from https://whitehall-admin.production.alphagov.co.uk/government/document_mappings.csv
fetcher.remap_new_urls_using(base_dir + "/document_mappings.csv")
fetcher.fetch
