#!/usr/bin/env ruby -w

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new(
  "https://docs.google.com/spreadsheet/pub?key=0AvP4F7CtEMi-dEhJQ2tvMzJsWmZZeTg5VERidGJkQWc&single=true&gid=0&output=csv",
  "mod"
)
fetcher.remap_new_urls_using(File.expand_path("../new_document_mappings.csv", File.dirname(__FILE__)))
fetcher.fetch