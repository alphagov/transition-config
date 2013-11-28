desc 'Add a new site to data/sites'
task :new_site, [:abbr, :whitehall_slug] do |_, args|
  site = Redirector::Site.create(args.abbr, args.whitehall_slug)
  site.save!
  puts site.filename
end
