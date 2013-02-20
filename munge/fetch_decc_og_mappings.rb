#!/usr/bin/env ruby

base_dir = File.expand_path("..", File.dirname(__FILE__))

require_relative "mapping_fetcher"
fetcher = MappingFetcher.new

# Note if there are duplicates then the FIRST mapping is used, so order matters here
fetcher.add_source(StringCsvSource.new($stdin))
{
  harvester: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE12clZ0NENINUFrcHNkenZiU1ZmQnc&single=true&gid=3&output=csv',
  furls: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE12clZ0NENINUFrcHNkenZiU1ZmQnc&single=true&gid=6&output=csv',
  manual: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE12clZ0NENINUFrcHNkenZiU1ZmQnc&single=true&gid=0&output=csv',
  sitemap: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE12clZ0NENINUFrcHNkenZiU1ZmQnc&single=true&gid=8&output=csv',
  analytics: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE12clZ0NENINUFrcHNkenZiU1ZmQnc&single=true&gid=4&output=csv',
  other: 'https://docs.google.com/spreadsheet/pub?key=0AlVEZKtKyUEvdE12clZ0NENINUFrcHNkenZiU1ZmQnc&single=true&gid=10&output=csv'
}.each do |_, url|
  fetcher.add_source(MappingFetcher::RemoteCsvSource.new(url))
end

fetcher.fetch
