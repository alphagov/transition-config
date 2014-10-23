require 'open-uri'
require 'nokogiri'

module Redirector
  class TNATimestamp
    def initialize(hostname)
      @hostname = hostname
    end

    def find
      begin
        response = open("http://webarchive.nationalarchives.gov.uk/*/http://#{@hostname}")
      rescue OpenURI::HTTPError
        puts "Couldn't find a crawl. Trying HTTPS..."
        begin
          response = open("http://webarchive.nationalarchives.gov.uk/*/https://#{@hostname}")
        rescue OpenURI::HTTPError
          $stderr.puts("TNA don't appear to have crawled this (yet) #{@hostname} Try the aliases?")
          return nil
        end
      end

      doc = Nokogiri::HTML(response)
      crawl_date_row = doc.css('div#pagemain table tr').last
      most_recent_crawl_link = crawl_date_row.css('td a').last
      url = URI.parse(most_recent_crawl_link['href'])
      url.path.split('/')[1]
    end
  end
end
