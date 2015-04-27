require 'transition-config'

def organisations_by_slug
  @_organisations_by_slug ||= TransitionConfig::Organisations.new.by_slug
end

def site_filenames
  @_site_filenames ||= Dir.glob("data/transition-sites/*.yml")
end

desc "Rake task to populate organisation_content_ids and extra_organisation_content_ids"
task :populate_content_ids do
  site_filenames.each do |filename|
    existing_site = Psych.load(File.read(filename))
    updated_site = {} # we want to insert the new keys at particular points, rather than append

    existing_site.each do |key, value|
      # Preserve every key
      updated_site[key] = value

      if key == "whitehall_slug" && !existing_site.keys.include?("organisation_content_id")
        organisation = organisations_by_slug[value]
        updated_site['organisation_content_id'] = organisation.details.content_id

      elsif key == "extra_organisation_slugs" && !existing_site.keys.include?("extra_organisation_content_ids")
        content_ids = existing_site['extra_organisation_slugs'].map do |slug|
          organisation = organisations_by_slug[slug]
          if organisation.nil?
            puts "ERROR No organisation for '#{slug}'"
            next
          end
          organisation.details.content_id
        end
        updated_site['extra_organisation_content_ids'] = content_ids
      end
    end

    File.open(filename, 'w') { |file| file.write(Psych.dump(updated_site)) }
  end
end
