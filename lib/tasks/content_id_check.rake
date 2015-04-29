require 'transition-config'

desc "Check that the organisation_content_ids exist and match the whitehall_slugs"
task :content_id_check do
  TransitionConfig::Site.check_all_organisation_content_ids!
  TransitionConfig::Site.check_slugs_match_content_ids!
end
