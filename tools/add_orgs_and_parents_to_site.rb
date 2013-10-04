require 'yaml'

##
# A one-shot script. If data/organisations exists, it's already been run
# and is here for historical reference (you could delete it, it'd be less obvious
# how orgs were arrived at).
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
    # when it has no parent or its title is different from that of its parent org
    def organisation?
      parent_org = @augmenter.org_sites[inferred_parent]
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
  # Derive orgs and parents for a set of site.yml files
  class SitesOrgAugmenter
    def initialize(*data_dirs)
      @masks = data_dirs.to_a.map do |dir|
        File.expand_path(File.join('..', 'data', dir, '*.yml')).tap { |j| puts "Processing #{j} ..." }
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
    # Only those sites that are directly for an org (no '_' in the site abbreviation)
    def org_sites
      sites.select { |_, site| !site.child? }
    end

    ##
    # Save each file
    def augment!
      sites.values.each { |site| site.save_with_inferred_values! }
    end
  end
end

def assert(actual, expected)
  raise RuntimeError, "Expected #{expected}, got #{actual}" unless expected == actual
end

processor = Transition::SitesOrgAugmenter.new('sites')
processor.sites.tap do |sites|
  assert sites['fco'].organisation?, true
  assert sites['fco'].child?, false
  assert sites['fco_ukinsomalia'].organisation?, false
  assert sites['fco_ukinsomalia'].child?, true
  assert sites['bis_ukaea'].organisation?, true
  assert sites['bis_ukaea'].child?, true
  assert sites['businesslink'].organisation?, true
  assert sites['businesslink'].child?, false
  assert sites['businesslink_budget'].organisation?, false
  assert sites['businesslink_budget'].child?, true
  assert sites['businesslink_budget'].child?, true
  assert sites['businesslink_budget'].ordered_output['parent'].nil?, false
  assert sites['businesslink_budget'].ordered_output['organisation'].nil?, true
end

processor.augment!
