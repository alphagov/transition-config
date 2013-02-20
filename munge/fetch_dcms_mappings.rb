#!/usr/bin/env ruby

require 'csv'
require_relative 'mapping_fetcher'

fetcher = MappingFetcher.new

fetcher.add_source(StringCsvSource.new($stdin))
# Note if there are duplicates then the FIRST mapping is used, so order matters here
{
  'Harvester Data' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdGpUckZ3OThKVUk5U1M5VFI3ZHc2cmc&output=csv&gid=3',
  'Friendly URLS' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdGpUckZ3OThKVUk5U1M5VFI3ZHc2cmc&output=csv&gid=6',
  'Manual Mappings' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdGpUckZ3OThKVUk5U1M5VFI3ZHc2cmc&output=csv&gid=0',
  'Sitemap' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdGpUckZ3OThKVUk5U1M5VFI3ZHc2cmc&output=csv&gid=4',
  'Analytics' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdGpUckZ3OThKVUk5U1M5VFI3ZHc2cmc&output=csv&gid=8',
  'Any other URLs' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdGpUckZ3OThKVUk5U1M5VFI3ZHc2cmc&output=csv&gid=10'
}.each do |_, url|
  fetcher.add_source(RemoteCsvSource.new(url))
end

fetcher.fetch
