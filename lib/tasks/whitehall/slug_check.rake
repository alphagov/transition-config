require 'redirector/site'

namespace :whitehall do
  desc 'Check that all sites here have slugs in Whitehall'

  task :slug_check do
    Redirector::Site.check_whitehall_slugs!
  end
end
