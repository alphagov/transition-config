#!/usr/bin/env ruby

# A test script to check the 418 propagation
# Committing as is. Can be made into a proper test if required, or removed after completion of story separating munge into pipeline
# Usage:
# ./munge/extract-mappings.rb www.test.gov.uk < ./munge/tests/test_mappings.csv | munge/test_adding_418s.rb
# Creates a data/mappings/test.csv

base_dir = File.expand_path("..", File.dirname(__FILE__))

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("test")

fetcher.add_source(MappingFetcher::StringCsvSource.new($stdin))
fetcher.remap_new_urls_using(base_dir + "/document_mappings.csv")
fetcher.fetch
