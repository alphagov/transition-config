module Redirector
  class Tests
    def self.create_default(args)
      tests_filename    = Redirector.path("data/tests/#{args.host}.csv")
      tests_csv = <<-CSV
Old Url,New Url,Status
http://#{args.host},https://www.gov.uk/government/organisations/#{args.whitehall_slug},301
CSV
      `echo -n '#{tests_csv}' > #{tests_filename}`
    end
  end
end
