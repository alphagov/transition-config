#!/usr/bin/env ruby

require 'yaml'
require 'csv'
require 'pp'
require 'uri'

SITES_DIR = File.dirname(__FILE__) + "/../data/sites/"
MAPPINGS_DIR = File.dirname(__FILE__) + "/../data/mappings/"

class Sites
  def initialize(dir)
    @sites = {}
    Dir["#{dir}/*.yml"].each do |d|
      add(Site.new(d))
    end
  end

  def add(site)
    @sites[site.host] = site
  end

  def all
    @sites
  end

  def for_host(host)
    @sites[host]
  end

  def save_all_mappings!
    @sites.each {|host, s| s.save_mappings!}
  end
end

class Site
  def initialize(filename)
    @yaml = YAML.load_file(filename)
  end

  def [](name)
    @yaml[name]
  end

  def method_missing(name)
    self[name.to_s]
  end

  def mappings
    @mappings ||= Mappings.new(self.filename)
  end

  def filename
    MAPPINGS_DIR + "#{self.site}.csv"
  end

  def add_mapping(mapping)
    self.mappings.add(mapping)
  end

  def save_mappings!
    self.mappings.save!
  end
end

class Mappings
  def initialize(filename)
    @filename = filename
    @dirty = false
  end

  def mappings
    @mappings ||= begin
      data = CSV.read(@filename, headers:true)
      if data.first
        @headings = data.first.headers
      else
        $stderr.puts "WARNING: #{@filename} has no rows"
        @headings = ['Old Url', 'New Url']
      end
      ensure_valid_headings!
      data.map {|row| Mapping.new(row)}
    end
  end

  def ensure_valid_headings!
    if @headings[0] != 'Old Url' || @headings[1] != 'New Url'
      raise "Invalid headings #{@headings} expected first two headings to be 'Old Url', 'New Url'"
    end
  end

  def add(mapping)
    if self.mappings.any? {|m| m.old_url == mapping.old_url}
      self.mappings.delete_if {|m| m.old_url == mapping.old_url}
      $stderr.puts "Replacing #{mapping.old_url}"
    end
    @dirty = true
    self.mappings << mapping
  end

  def dirty?
    @dirty
  end

  def save!
    return unless dirty?
    puts "Saving #{@filename}"

    self.mappings
    CSV.open(@filename, "w:utf-8") do |csv|
      csv << @headings

      self.mappings.reject(&:empty?).sort_by {|m| m.old_url.to_s}.each do |mapping|
        csv << ([mapping.old_url, mapping.new_url] + mapping.extra_columns)
      end
    end
  end
end

class Mapping
  def initialize(row)
    @row = row
  end

  def old_url
    @row['Old Url']
  end

  def new_url
    @row['New Url']
  end

  def empty?
    (old_url.nil? || old_url.strip.empty?) && (new_url.nil? || new_url.strip.empty?)
  end

  def extra_columns
    @row.fields[2..-1] || []
  end

  def source_host
    URI.parse(@row['Old Url']).host
  end

  def to_s
    "#{old_url} => #{new_url}"
  end
end

sites = Sites.new(SITES_DIR)

unless ARGV.size == 1
  $stderr.puts "USAGE: #{File.basename($0)} <input file>"
end

input_file = ARGV.first

mappings_to_ingest = Mappings.new(input_file)

mappings_to_ingest.mappings.each do |mapping|
  site = sites.for_host(mapping.source_host)
  site.add_mapping(mapping)
end

sites.save_all_mappings!