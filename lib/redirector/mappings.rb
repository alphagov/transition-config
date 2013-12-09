module Redirector
  class Mappings
    def self.create_default(site_abbr)
      mappings_csv_path = Redirector.path("data/mappings/#{site_abbr}.csv")
      `echo 'Old Url,New Url,Status,Suggested Link,Archive Link' > #{mappings_csv_path}`
    end
  end
end
