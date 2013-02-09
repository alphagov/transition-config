#!/usr/bin/env ruby -w

base_dir = File.expand_path("..", File.dirname(__FILE__))
harvester_results_url = "https://docs.google.com/spreadsheet/pub?key=0AiP6zL-gKn64dHd5MXB5Q0h4SFRIQ3huRDBIb29nY2c&single=true&gid=3&output=csv"
missing_mappings_url = "https://docs.google.com/spreadsheet/pub?key=0Au2ZT9FFPER-dDViRm16RElvbmttNFBYZEFpRHJTalE&single=true&gid=0&output=csv"

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("mod")

# Note if there are duplicates then the FIRST mapping is used, so order matters here
fetcher.add_source(MappingFetcher::LocalCsvSource.new(base_dir + "/tools/mod_supplemental_data/mappings_of_imported_mod_docs.csv"))
fetcher.add_source(MappingFetcher::RemoteCsvSource.new(harvester_results_url))
fetcher.add_source(MappingFetcher::RemoteCsvSource.new(missing_mappings_url))

# This is in transition data
fetcher.remap_new_urls_using(base_dir + "/../transition-data/whitehall-data/document_mappings.csv")

# download this from https://whitehall-admin.production.alphagov.co.uk/government/document_mappings.csv
fetcher.remap_new_urls_using(base_dir + "/document_mappings.csv")
fetcher.fetch
