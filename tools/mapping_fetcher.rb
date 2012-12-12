require 'csv'
require 'uri'
require 'net/http'
require 'pathname'

class MappingFetcher
  attr_reader :csv_url, :mapping_name

  def initialize(csv_url, mapping_name)
    @csv_url = csv_url
    @mapping_name = mapping_name
    @admin_url_mappings = {}
  end

  def remap_new_urls_using(admin_url_mapping_csv_file)
    data = File.open(admin_url_mapping_csv_file, 'r:utf-8') { |f| f.read}

    CSV.parse(data, headers: true, header_converters: [NilAsBlankConverter, :downcase]).each do |row|
      if row['admin url'] =~ /whitehall-admin/ && row['new url'] && !row['new url'].empty?
        @admin_url_mappings[row['admin url']] = row['new url']
      end
    end
  end

  def fetch
    CSV.open(output_file, "w:utf-8") do |output_csv|
      puts "Writing #{mapping_name} mappings to #{output_file}"
      output_csv << ['Old Url','New Url','Status']
      i = 0
      rows = ensure_no_duplicates(
        sanitize_urls(
          remap_new_urls(
            skip_rows_with_blank_or_invalid_old_url(input_csv))))
      rows.sort_by {|row| row['old url']}.each do |row|
        new_row = [
          row['old url'],
          row['new url'],
          blank?(row['new url']) ? "410" : "301"
        ]
        validate_row!(new_row)
        output_csv << new_row
        i += 1
      end
      puts "Wrote #{i} mappings"
    end
  end

  def remap_new_urls(rows)
    Enumerator.new do |yielder|
      rows.each do |row|
        new_url = remap_new_url(row['new url'])
        row['new url'] = valid_destination_url?(new_url) ? new_url : ""
        yielder << row
      end
    end
  end

  def sanitize_urls(rows)
    Enumerator.new do |yielder|
      rows.each do |row|
        row['old url'] = sanitize_url(row['old url'])
        row['new url'] = sanitize_url(row['new url'])
        yielder << row
      end
    end
  end

  def skip_rows_with_blank_or_invalid_old_url(rows)
    Enumerator.new do |yielder|
      rows.each_with_index do |row, i|
        if blank?(row['old url'])
          $stderr.puts "Row #{i+2}: skipping - blank old url"
        elsif !valid_url?(row['old url'])
          $stderr.puts "Row #{i+2}: skipping - invalid old url '#{row['old url']}'"
        else
          yielder << row
        end
      end
    end
  end

  def duplicates(rows)
    rows.group_by {|row| row['old url']}.select { |old_url, cluster| cluster.size > 1}
  end

  def non_duplicates(rows)
    rows.group_by {|row| row['old url']}.reject { |old_url, cluster| cluster.size > 1}.map {|old_url, rows| rows.first}
  end

  def prefer_page_destinations_over_assets(rows)
    deduped_clusters = duplicates(rows).map do |old_url, cluster|
      dedup_cluster(cluster)
    end
    deduped_clusters.flatten(1) + non_duplicates(rows)
  end

  def dedup_cluster(cluster)
    categories = cluster.map {|row| row['new url']}.uniq.map {|new_url| categorise_new_url(new_url)}
    if categories.size == 2 && categories.include?(:asset) && categories.include?(:page)
      cluster.select {|row| categorise_new_url(row) == :page }
    else
      [cluster.first]
    end
  end

  def remap_new_url(new_url)
    @admin_url_mappings[new_url] || new_url
  end

  def categorise_new_url(new_url)
    case new_url
    when %r{https://www\.gov\.uk/government/uploads/} then :asset
    when %r{https://www\.gov\.uk/government/} then :page
    else nil
    end
  end

  def ensure_no_duplicates(rows)
    deduped = prefer_page_destinations_over_assets(rows)
    if duplicates(deduped).any?
      dup_description = duplicates(deduped).map {|url, c| "#{url} -> \n  #{c.map {|r| r['new url']}.join("\n  ")}"}.join("\n")
      raise "There were some duplicates old urls: '#{dup_description}'"
    end
    deduped
  end

  def valid_destination_url?(url)
    must_not_be_whitehall_admin!(url)
    !on_national_archives?(url) && !blank?(url) && !is_whitehall_admin?(url) && valid_url?(url)
  end

  def is_whitehall_admin?(url)
    url =~ /whitehall-admin/
  end

  def must_not_be_whitehall_admin!(url)
    $stderr.puts "Destination urls must not be whitehall-admin - '#{url}'" if is_whitehall_admin?(url)
  end

  def blank?(url)
    url.nil? || url.strip.empty?
  end

  def on_national_archives?(url)
    url && url.start_with?("http://webarchive.nationalarchives.gov.uk/")
  end

  def validate_row!(new_row)
    new_row[0..1].each do |url|
      next if url.nil? || url.empty?
      valid_url?(url) || raise("Invalid URL: '#{url}'")
    end
  end

  def valid_url?(url)
    url && url =~ %r{^https?://} && URI.parse(url)
  rescue
    false
  end

  def sanitize_url(url)
    url && url.gsub(" ", "%20")
  end

  def output_file
    Pathname.new(File.dirname(__FILE__)) + ".." + "data/mappings/#{mapping_name}.csv"
  end

  private

  NilAsBlankConverter = ->(heading) { heading || "" }

  def input_csv
    @input_csv ||= CSV.parse(do_request(csv_url).body.force_encoding("UTF-8"), headers: true, header_converters: [NilAsBlankConverter, :downcase])
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