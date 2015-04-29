require 'transition-config'

namespace :whitehall do
  desc 'Check that all sites here have slugs in Whitehall'
  task :slug_check do
    TransitionConfig::Site.check_all_slugs!
  end
end
