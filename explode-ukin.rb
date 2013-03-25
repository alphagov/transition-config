#!/usr/bin/env ruby

require 'yaml'
require 'csv'
require 'pp'

fco_ukin = YAML.load_file("data/sites/fco_ukin.yml")

class Mappings
  def initialize
    @data = CSV.read('data/mappings/fco_ukin.csv', headers:true)
  end

  def homepage_for(host)
    found_row = @data.find do |row|
      row['Old Url'] == "http://#{host}/en"
    end
    if found_row
      found_row['New Url']
    else
      $stderr.puts "Can't find homepage for #{host}"
    end
  end
end

mappings = Mappings.new

fco_ukin['servers'].each do |host|
  unless host =~ /^(.*)\.fco\.gov\.uk$/
    $stderr.puts "WARNING: Can't parse #{host}"
    next
  end
  name = $1
  homepage = mappings.homepage_for(host)

  outputfile = "data/sites/#{name}.yml"
  File.open(outputfile, 'w') do |f|
f << %Q{---
site: #{name}
host: #{host}
redirection_date: 25th March 2013
tna_timestamp: 20130217073211
title: Foreign &amp; Commonwealth Office
furl: www.gov.uk/fco
homepage: #{homepage}
options: --query-string id
---
}
  p "Wrote #{outputfile}"
  end
end