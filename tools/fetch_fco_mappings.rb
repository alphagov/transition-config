#!/usr/bin/env ruby -w
require 'csv'
require 'uri'
require 'net/http'
require 'pathname'

class FetchFcoMappings

  def fetch
    CSV.open(output_file, "w:utf-8") do |output_csv|
      puts "Writing FCO mappings to #{output_file}"
      output_csv << ['Old Url','New Url','Status']
      i = 0
      ensure_no_duplicates(input_csv.sort_by {|row| row['old url']}).each do |row|
        old_url = sanitize_url(row['old url'])
        new_url = sanitize_url(row['new url'])
        new_row = if valid_destination_url?(new_url)
          [old_url, new_url, "301"]
        else
          [old_url, "", "410"]
        end
        validate_row!(new_row)
        output_csv << new_row
        i += 1
      end
      puts "Wrote #{i} mappings"
    end
  end

  def ensure_no_duplicates(rows)
    duplicates = rows.group_by {|row| row['old url']}.select { |old_url, cluster| cluster.size > 1}
    if duplicates.any?
      raise "There were some duplicates old urls: '#{duplicates.keys.inspect}'"
    end
    rows
  end

  def valid_destination_url?(url)
    !on_national_archives?(url) && !blank?(url)
  end

  def blank?(url)
    url.nil? || url.strip.empty?
  end

  def on_national_archives?(url)
    url && url.start_with?("http://webarchive.nationalarchives.gov.uk/")
  end

  def validate_row!(row)
    row[0..1].each do |url|
      next if url.nil? || url.empty?
      valid_url?(url) || raise("Invalid URL: '#{url}'")
    end
  end

  def valid_url?(url)
    URI.parse(url) rescue false
  end

  def sanitize_url(url)
    url && url.gsub(" ", "%20")
  end

  def csv_url
    "https://docs.google.com/spreadsheet/pub?key=0AiP6zL-gKn64dHMycTBlNjJrUV9CcVZGMGpHcERLYmc&output=csv"
  end

  def output_file
    Pathname.new(File.dirname(__FILE__)) + ".." + "data/mappings/fco.csv"
  end

  private

  def input_csv
    @input_csv ||= CSV.parse(do_request(csv_url).body.force_encoding("UTF-8"), headers: true, header_converters: :downcase)
  end

  def do_request(url)
    uri = URI.parse(url)
    raise "url must be HTTP(S)" unless uri.is_a?(URI::HTTP)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.is_a?(URI::HTTPS))
    response = http.request_get(uri.path + "?" + uri.query)
    raise "Error - got response #{response.code}" unless response.is_a?(Net::HTTPOK)
    response
  end
end

FetchFcoMappings.new.fetch