#!/usr/bin/env ruby -w

base_dir = File.expand_path("..", File.dirname(__FILE__))

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("cabinetoffice")

fetcher.add_source(MappingFetcher::StringCsvSource.new($stdin))
# Note if there are duplicates then the FIRST mapping is used, so order matters here
{
  'Harvester Data' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdFh0UHJ4RXEzUm1UMDFCSlJESEhFcEE&output=csv&gid=3',
  'Friendly URLS' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdFh0UHJ4RXEzUm1UMDFCSlJESEhFcEE&output=csv&gid=6',
  'Manual Mappings' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdFh0UHJ4RXEzUm1UMDFCSlJESEhFcEE&output=csv&gid=0',
  'Sitemap' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdFh0UHJ4RXEzUm1UMDFCSlJESEhFcEE&output=csv&gid=4',
  'Analytics' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdFh0UHJ4RXEzUm1UMDFCSlJESEhFcEE&output=csv&gid=8',
  'Any other URLs' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdFh0UHJ4RXEzUm1UMDFCSlJESEhFcEE&output=csv&gid=10'
}.each do |_, url|
  fetcher.add_source(MappingFetcher::RemoteCsvSource.new(url))
end

# download this from https://whitehall-admin.production.alphagov.co.uk/government/document_mappings.csv
fetcher.remap_new_urls_using(base_dir + "/document_mappings.csv")
fetcher.fetch