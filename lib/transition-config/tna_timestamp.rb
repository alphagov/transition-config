# frozen_string_literal: true

require "open-uri"
require "nokogiri"

module TransitionConfig
  class TNATimestamp
    TNA_BASE_URL = "http://webarchive.nationalarchives.gov.uk"

    def initialize(hostname)
      @hostname = hostname
    end

    def find
      begin
        response = URI.open("#{TNA_BASE_URL}/+/http://#{@hostname}")
      rescue OpenURI::HTTPError
        puts "Couldn't find a crawl. Trying HTTPS..."
        begin
          response = URI.open("#{TNA_BASE_URL}/+/https://#{@hostname}")
        rescue OpenURI::HTTPError
          warn("TNA don't appear to have crawled this (yet) #{@hostname} Try the aliases?")
          return nil
        end
      end

      doc = Nokogiri::HTML(response)
      most_recent_crawl_link = doc.xpath('//*[@id="header"]/div/div[1]/ul/li[6]/a').last

      return nil unless most_recent_crawl_link

      url = URI.parse(most_recent_crawl_link["href"])
      url.path.split("/")[1]
    end
  end
end
