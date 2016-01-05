require 'transition-config'

namespace :sites do
  desc "Check that each site's abbr matches its filename"
  task :validate do
    TransitionConfig::Site.validate!
  end

  desc "Check that no YAML files are outside the expected locations"
  task :check_yaml_files_not_in_unexpected_locations do
    re = Regexp.union([
      /data\/transition-sites/,
      /tests\/fixtures/,
      /vendor/,
    ])
    bad_yamls = Dir.glob('**/*.yml').reject { |path| path.match(re) }
    if bad_yamls.size != 0
      msg = "YAML files found outside the expected directories:\n"
      msg += bad_yamls.join("\n")
      msg += "\n\nDid you mean to configure a new site in data/transition-sites/?"
      abort(msg)
    end
  end
end
