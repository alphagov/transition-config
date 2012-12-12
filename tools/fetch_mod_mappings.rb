#!/usr/bin/env ruby -w

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("mod")

harvester_results_url = "https://docs.google.com/spreadsheet/pub?key=0AiP6zL-gKn64dHd5MXB5Q0h4SFRIQ3huRDBIb29nY2c&single=true&gid=3&output=csv"
fetcher.add_source(MappingFetcher::RemoteCsvSource.new(harvester_results_url))
fetcher.add_source(MappingFetcher::LocalCsvSource.new("mappings_of_imported_mod_docs.csv"))
fetcher.remap_new_urls_using(File.expand_path("../new_document_mappings.csv", File.dirname(__FILE__)))
fetcher.remap_new_urls_using(File.expand_path("../document_mappings.csv", File.dirname(__FILE__)))
fetcher.fetch
