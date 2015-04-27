require 'transition-config'

def organisations_by_slug
  @_organisations_by_slug ||= TransitionConfig::Organisations.new.by_slug
end

def site_filenames
  @_site_filenames ||= Dir.glob("data/transition-sites/*.yml")
end

task :populate_content_ids do
  site_filenames.each do |filename|
    existing_site = Psych.load(File.read(filename))
    updated_site = {} # we want to insert the new keys at particular points, rather than append

    existing_site.each do |key, value|
      # Preserve every key
      updated_site[key] = value
    end

    File.open(filename, 'w') { |file| file.write(Psych.dump(updated_site)) }
  end
end
