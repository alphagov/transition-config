#!/usr/bin/env ruby -w

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new("fco")
fetcher.add_source(
  MappingFetcher::RemoteCsvSource.new("https://docs.google.com/spreadsheet/pub?key=0AiP6zL-gKn64dHMycTBlNjJrUV9CcVZGMGpHcERLYmc&output=csv")
)
fetcher.fetch