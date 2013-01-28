#!/usr/bin/env ruby -w

base_dir = File.expand_path("..", File.dirname(__FILE__))

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("scotlandoffice")

fetcher.add_source(MappingFetcher::LocalCsvSource.new(base_dir + "/tools/scotland_supplemental_data/mappings_of_imported_scotland_docs.csv"))
# Note if there are duplicates then the FIRST mapping is used, so order matters here
{
  'Harvester Data' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE5Wa2ZvR25hOEx3bEk5dmc4Z0RZVXc&single=true&gid=3&output=csv',
  'Friendly URLS' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE5Wa2ZvR25hOEx3bEk5dmc4Z0RZVXc&single=true&gid=6&output=csv',
  'Manual Mappings' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE5Wa2ZvR25hOEx3bEk5dmc4Z0RZVXc&single=true&gid=0&output=csv',
  'Sitemap' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE5Wa2ZvR25hOEx3bEk5dmc4Z0RZVXc&single=true&gid=4&output=csv',
  'Analytics' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE5Wa2ZvR25hOEx3bEk5dmc4Z0RZVXc&single=true&gid=8&output=csv',
  'Any other URLs' => 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE5Wa2ZvR25hOEx3bEk5dmc4Z0RZVXc&single=true&gid=10&output=csv'
}.each do |_, url|
  fetcher.add_source(MappingFetcher::RemoteCsvSource.new(url))
end

# download this from https://whitehall-admin.production.alphagov.co.uk/government/document_mappings.csv
fetcher.remap_new_urls_using(base_dir + "/document_mappings.csv")
fetcher.fetch
