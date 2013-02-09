require 'csv'

EXCLUDE_ARCHIVED = true

NilAsBlankConverter = ->(heading) { heading || "" }

mod_mappings = {}
CSV.read("data/mappings/mod.csv", headers:true, header_converters: [NilAsBlankConverter, :downcase]).each do |row|
  if EXCLUDE_ARCHIVED
    next if row['new url'].nil? || row['new url'].strip.empty?
  end
  mod_mappings[row['old url'].downcase] = row
end

basedir = File.dirname(__FILE__) + "/validate_mod_mappings_data/"

errors = CSV.generate do |csv|
  csv << ['Source', 'url', 'visits']

  sitemap = File.open(basedir + "mod-sitemap.txt", "r:utf-8").read.split("\r\n").grep %r{http://www.mod.uk}
  sitemap.each do |url|
    next if url.nil?
    if !mod_mappings.has_key?(url.downcase)
      csv << ['sitemap', url]
    end
  end

  analytics = CSV.read(basedir + "mod-analytics.csv", headers:true, header_converters: [NilAsBlankConverter, :downcase])

  analytics.each do |row|
    next if row['url'].nil?
    if !mod_mappings.has_key?(row['url'].downcase)
      csv << ['Analytics', row['url'], row['visits']]
    end
  end
end

puts errors