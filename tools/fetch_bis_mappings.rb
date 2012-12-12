#!/usr/bin/env ruby -w

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("bis")
fetcher.add_source(
  MappingFetcher::RemoteCsvSource.new("https://docs.google.com/spreadsheet/pub?key=0AiP6zL-gKn64dEw3N1VFX1BWei1pMnkwcS1UYmVVbGc&output=csv"))

fetcher.remap_new_urls_using(File.expand_path("../new_document_mappings.csv", File.dirname(__FILE__)))
fetcher.fetch