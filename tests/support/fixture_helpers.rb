module FixtureHelpers
  def site_filename(abbr)
    File.expand_path("../../../data/sites/#{abbr}.yml", __FILE__).tap {|f| puts f}
  end
end
