require 'redirector'

desc 'Add a new site to data/transition-sites. Use SITE_TYPE=redirector to specify redirector site.'
task :new_site, [:abbr, :whitehall_slug, :host] do |_, args|
  errors = [:abbr, :whitehall_slug, :host].inject([]) do |errors, arg|
    args.send(arg).nil? ? errors << arg : errors
  end

  unless errors.empty?
    puts "#{errors.map { |e| e.to_s }.join(',')} required.\n"\
         "Usage:\n\trake new_site[abbr,whitehall_slug,host]"
    exit
  end

  type = (ENV['SITE_TYPE'] || 'bouncer').downcase.to_sym

  site = Redirector::Site.create(
    args.abbr, args.whitehall_slug, args.host, {type: type})
  site.save!

  if type == :redirector
    Redirector::Mappings.create_default(args.abbr)
    Redirector::Tests.create_default(args)
  end

  puts site.filename
end
