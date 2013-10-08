require 'yaml'

##
# A one-shot script. If data/organisations exists, it's already been run
# and is here for historical reference (you could delete it).
#
# It generates organisations from sites.
#
# It adds organisation: and parent: fields inferred from sites alone
# and uses title: to determine what's an organisation by looking at
# other site YAML
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
    def organisation?
      parent_org = @augmenter.departments[inferred_parent]
      parent_org.nil? || (parent_org.title != title)
    end

    def inferred_organisation
      abbr.split('_').last
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
        ordered_dup['organisation'] = inferred_organisation if organisation?
        ordered_dup['parent']       = inferred_parent if child?
        ordered_dup.merge!(yaml)
      end
    end

    def to_s
      abbr
    end
  end

  ##
  # An org inferred from a site's details
  class Organisation < Struct.new(:site)
    def ordered_output
      @ordered_output ||= begin
        site_hash = site.ordered_output
        %w(organisation title redirection_date furl homepage).inject({}) do |yaml, key|
          yaml[key] = site_hash[key]
          yaml
        end
      end
    end

    def filename
      File.join(SitesOrgAugmenter::REDIRECTOR_DATA_PATH, 'organisations', "#{site.inferred_organisation}.yml")
    end

    def save!
      File.open(filename, 'w') { |file| ordered_output.to_yaml(file) } unless File.exists?(filename)
    end
  end

  ##
  # Derive orgs and parents for a set of site.yml files
  class SitesOrgAugmenter
    REDIRECTOR_DATA_PATH = File.join('..', 'data')

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
      sites.values.each { |site| site.save_with_inferred_values! }
    end

    ##
    # Generate orgs
    def generate_orgs!
      require 'fileutils'
      FileUtils.mkdir_p File.join(REDIRECTOR_DATA_PATH, 'organisations')
      organisations.values.map { |site| Organisation.new(site).save! }
    end
  end
end

Transition::SitesOrgAugmenter.new('sites').tap do |augmenter|
  augmenter.generate_orgs!
  augmenter.augment!
end
