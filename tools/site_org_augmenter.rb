require 'yaml'
require 'forwardable'
require 'gds_api/organisations'
require 'htmlentities'

##
# A script to add whitehall slugs to the sites YAML for any orgs with a matching title.
module Transition
  ##
  # A transition-centric view over redirector yaml
  # to infer parent and org
  class Site < Struct.new(:path, :yaml)
    def abbr
      yaml['site']
    end

    ##
    # A Site is an organisation from the point of view of Transition either
    # when it has no parent or its title is different from that of its parent department
    # (except in the case of the Wales Office, which has a separate Welsh language site!)
    def organisation?
      parent_org = @augmenter.departments[inferred_parent]
      parent_org.nil? || (parent_org.title != title && title != 'Swyddfa Cymru')
    end

    def inferred_organisation
      abbr.split('_').last
    end

    def whitehall_slug
      decoded_title = HTMLEntities.new.decode(title)
      org = @augmenter.whitehall_organisations[decoded_title]
      org.details.slug rescue $stderr.puts "No slug found for #{decoded_title}"
    end

    def title
      yaml['title']
    end

    def child?
      abbr.include?('_')
    end

    def inferred_parent
      abbr.split('_').first if child? # nil otherwise
    end

    def augmenter=(value)
      @augmenter = value
    end

    def save_with_inferred_values!
      File.open(path, 'w') { |file| ordered_output.to_yaml(file) }
    end

    def ordered_output
      {}.tap do |ordered_dup|
        ordered_dup['site'] = abbr
        ordered_dup['whitehall_slug'] = whitehall_slug if whitehall_slug
        ordered_dup.merge!(yaml)
      end
    end

    def to_s
      abbr
    end
  end

  ##
  # Derive orgs and parents for a set of site.yml files
  class SitesOrgAugmenter
    REDIRECTOR_DATA_PATH = 'data'

    def initialize(*data_dirs)
      @masks = data_dirs.to_a.map do |dir|
        File.expand_path(File.join(REDIRECTOR_DATA_PATH, dir, '*.yml')).tap { |j| puts "Processing #{j} ..." }
      end
    end

    ##
    # All sites
    def sites
      @sites ||= load_sites
    end

    def load_sites
      {}.tap do |sites_hash|
        @masks.each do |mask|
          Dir[mask].each do |filename|
            site_yaml                     = YAML::load(File.read(filename))
            sites_hash[site_yaml['site']] = Site.new(filename, site_yaml).tap { |s| s.augmenter = self }
          end
        end
      end
    end

    ##
    # Only departmental sites (no '_' in the site abbreviation)
    # (in other words, sites that are eligible to be parents)
    def departments
      sites.select { |_, site| !site.child? }
    end

    ##
    # All orgs (things that are not *just* sites)
    def organisations
      sites.select { |_, site| site.organisation? }
    end

    ##
    # Save each file
    def augment!
      sites.values.each do |site|
        site.save_with_inferred_values!
      end
    end

    ##
    # Place to put complete cached copy of orgs API
    def cached_org_path
      "/tmp/orgs_augmenter_orgs-#{DateTime.now.strftime('%Y-%m-%d')}.yaml"
    end

    def whitehall_organisations
      @organisations ||= begin
        return YAML.load(File.read(cached_org_path)) if File.exist?(cached_org_path)

        api = GdsApi::Organisations.new('https://www.gov.uk')

        api.organisations.with_subsequent_pages.to_a.inject({}) do |orgs, org|
          orgs[org.title] = org
          orgs
        end.tap do |orgs_by_title|
          File.open(cached_org_path, 'w') { |f| f.write(YAML.dump(orgs_by_title)) }
        end
      end
    end
  end
end

Transition::SitesOrgAugmenter.new('sites').tap do |augmenter|
  augmenter.augment!
end
