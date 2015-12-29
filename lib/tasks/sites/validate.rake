require 'transition-config'

namespace :sites do
  desc "Check that each site's abbr matches its filename"
  task :validate do
    TransitionConfig::Site.validate!
  end
end
