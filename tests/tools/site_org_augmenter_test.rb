require 'minitest/unit'
require 'minitest/autorun'
require_relative '../../tools/site_org_augmenter'

class SiteOrgAugmenterTest < MiniTest::Unit::TestCase
  SITES_DATA_PATH = File.join('..', '..', 'data', 'sites')

  def test_simple_mappings
    Transition::SitesOrgAugmenter.new(SITES_DATA_PATH).tap do |augmenter|
      assert augmenter.organisations.include?('bis_ukaea'), true
      augmenter.sites.tap do |sites|
        assert sites['fco'].organisation?
        refute sites['fco'].child?
        refute sites['fco_ukinsomalia'].organisation?
        assert sites['fco_ukinsomalia'].child?
        assert sites['bis_ukaea'].organisation?
        assert sites['bis_ukaea'].child?
        assert sites['businesslink'].organisation?
        refute sites['businesslink'].child?
        refute sites['businesslink_budget'].organisation?
        assert sites['businesslink_budget'].child?
        assert sites['businesslink_budget'].child?
        refute sites['businesslink_budget'].ordered_output['parent'].nil?
        assert sites['businesslink_budget'].ordered_output['organisation'].nil?
      end
    end
  end
end
