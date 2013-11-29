require 'redirector'

module FilenameHelpers
  def site_filename(abbr)
    Redirector.path "data/sites/#{abbr}.yml"
  end

  def slug_check_site_filename(abbr)
    relative_to_tests "fixtures/slug_check_sites/#{abbr}.yml"
  end

  def relative_to_tests(part)
    File.expand_path "../../#{part}", __FILE__
  end
end
