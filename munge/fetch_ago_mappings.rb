#!/usr/bin/env ruby

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("ago")
fetcher.add_source(
  MappingFetcher::RemoteCsvSource.new("https://docs.google.com/spreadsheet/pub?key=0AiP6zL-gKn64dFZ4UWJoeXR4eV9TTFk3SVl6VTQzQ2c&single=true&gid=0&output=csv")
)
fetcher.fetch
