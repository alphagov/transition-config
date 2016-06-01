#!/usr/bin/env ruby
require_relative '../../test_helper'

require 'gds_api/test_helpers/organisations'

class TransitionConfigSiteTest < MiniTest::Unit::TestCase
  include GdsApi::TestHelpers::Organisations
  include FilenameHelpers

  def setup
    @old_app_domain = ORGANISATIONS_API_ENDPOINT
    ORGANISATIONS_API_ENDPOINT.gsub!(/^.*$/, 'https://www.gov.uk')
  end

  def teardown
    ORGANISATIONS_API_ENDPOINT.gsub!(/^.*$/, @old_app_domain)
  end

  def test_can_initialize_site_from_yml
    site = TransitionConfig::Site.from_yaml(slug_check_site_filename('ago'))
    assert_equal 'attorney-generals-office', site.whitehall_slug
    assert_equal 'ago', site.abbr
  end

  def test_all_hosts_with_aliases_present
    site = TransitionConfig::Site.from_yaml(duplicate_hosts_site_filename('one'))
    assert_equal ['one.local', 'alias1.one.local', 'alias2.one.local', 'two.local'], site.all_hosts
  end

  def test_all_hosts_without_aliases_present
    site = TransitionConfig::Site.from_yaml(duplicate_hosts_site_filename('two'))
    assert_equal ['two.local'], site.all_hosts
  end

  def test_can_enumerate_all_sites
    organisations_api_has_organisations(%w(attorney-generals-office))
    test_masks = [
      TransitionConfig.path('tests/fixtures/sites/*.yml'),
      TransitionConfig.path('tests/fixtures/slug_check_sites/*.yml')
    ]
    number_of_sites = test_masks.map {|mask| Dir[mask].length }.reduce(&:+)
    assert_equal number_of_sites, TransitionConfig::Site.all(test_masks).length
  end

  def test_all_raises_error_when_no_files
    assert_raises(RuntimeError) do
      TransitionConfig::Site.all(relative_to_tests('fixtures/nosites/*.yml'))
    end
  end

  def test_site_has_whitehall_slug
    slug = TransitionConfig::Site.from_yaml(slug_check_site_filename('ago')).whitehall_slug
    assert_instance_of String, slug
  end

  def test_existing_site_slug_exists_in_whitehall?
    organisations_api_has_organisations(%w(attorney-generals-office))
    ago = TransitionConfig::Site.from_yaml(slug_check_site_filename('ago'))
    assert ago.slug_exists_in_whitehall?(ago.whitehall_slug),
           "expected #{ago.whitehall_slug} to exist in whitehall"
  end

  def test_non_existing_site_slug_does_not_exist_in_whitehall?
    organisations_api_has_organisations(%w(nothing-interesting))
    ago = TransitionConfig::Site.from_yaml(slug_check_site_filename('ago'))
    refute ago.slug_exists_in_whitehall?(ago.whitehall_slug),
           'expected slug "attorney-generals-office" not to exist in Mock whitehall'
  end

  def test_all_slugs_with_extra_organisation_slugs
    bis = TransitionConfig::Site.from_yaml(slug_check_site_filename('bis'))
    expected_slugs = ['department-for-business-innovation-skills',
                      'government-office-for-science',
                      'made-up-slug']
    assert_equal expected_slugs, bis.all_slugs
  end

  def test_all_slugs_with_only_whitehall_slug
    ago = TransitionConfig::Site.from_yaml(slug_check_site_filename('ago'))
    assert_equal ['attorney-generals-office'], ago.all_slugs
  end

  def test_missing_slugs
    organisations_api_has_organisations(%w(government-office-for-science
                                           department-for-business-innovation-skills))

    bis = TransitionConfig::Site.from_yaml(slug_check_site_filename('bis'))
    assert_equal ['made-up-slug'], bis.missing_slugs
  end

  def test_checks_all_slugs
    organisations_api_has_organisations(%w(attorney-generals-office
                                           department-for-business-innovation-skills
                                           government-office-for-science))

    exception = assert_raises(TransitionConfig::SlugsMissingException) do
      TransitionConfig::Site.check_all_slugs!(relative_to_tests('fixtures/slug_check_sites/*.yml'))
    end

    assert_equal ['non-existent-slug'], exception.missing['nonexistent']
    assert_equal ['made-up-slug'], exception.missing['bis']
  end

  def test_checks_abbrs_match_filenames
    exception = assert_raises(TransitionConfig::AbbrFilenameMismatchesException) do
      TransitionConfig::Site.check_abbrs_match_filenames!(relative_to_tests('fixtures/abbr_filename_mismatch/*.yml'))
    end

    expected = { 'one' => 'won' }
    assert_equal expected, exception.mismatches
  end

  def test_checks_required_fields_are_present
    exception = assert_raises(TransitionConfig::RequiredFieldsMissingException) do
      TransitionConfig::Site.check_required_fields_present!(relative_to_tests('fixtures/required_fields_missing/*.yml'))
    end

    expected = {
      'bis' => ['whitehall_slug', 'host', 'tna_timestamp', 'homepage'],
      'ccs' => ['site'],
    }
    assert_equal expected, exception.missing
  end

  def test_checks_required_homepage_protocols_present
    exception = assert_raises(TransitionConfig::RequiredHomepageProtocolException) do
      TransitionConfig::Site.check_homepage_protocol_present!(relative_to_tests('fixtures/required_homepage_protocol_missing/*.yml'))
    end

    expected = ['ago', 'bis']
    assert_equal expected, exception.missing.sort
  end

  def test_site_create_fails_when_no_slug
    organisations_api_does_not_have_organisation 'non-existent-whitehall-slug'

    assert_raises(ArgumentError) do
      TransitionConfig::Site.create('foobar', 'non-existent-whitehall-slug', 'some.host.gov')
    end
  end

  def test_site_create_fails_on_unknown_type
    organisations_api_has_organisations(%w(uk-borders-agency))
    assert_raises(ArgumentError) do
      TransitionConfig::Site.create('ukba', 'uk-borders-agency', 'www.ukba.homeoffice.gov.uk', type: :foobar)
    end
  end

  def test_site_creates_yaml_when_slug_exists
    tna_response = File.read(relative_to_tests('fixtures/tna/ukba.html'))
    stub_request(:get, "http://webarchive.nationalarchives.gov.uk/+/http://www.ukba.homeoffice.gov.uk").
        to_return(status: 200, body: tna_response)

    organisation_details = organisation_details_for_slug('uk-borders-agency').tap do |details|
      details['title'] = 'UK Borders Agency & encoding test'
    end
    organisations_api_has_organisation 'uk-borders-agency', organisation_details

    site = TransitionConfig::Site.create('ukba', 'uk-borders-agency', 'www.ukba.homeoffice.gov.uk')

    assert site.filename.include?('data/transition-sites'),
           'site.filename should include data/transition-sites'

    assert_equal 'ukba', site.abbr
    assert_equal 'uk-borders-agency', site.whitehall_slug
    assert_equal 'www.ukba.homeoffice.gov.uk', site.host

    site.save!

    begin
      yaml = YAML.load(File.read(site.filename))

      assert_equal 'ukba', yaml['site']
      assert_equal 'uk-borders-agency', yaml['whitehall_slug']
      assert_equal 'https://www.gov.uk/government/organisations/uk-borders-agency', yaml['homepage']
      assert_equal 20150423114915, yaml['tna_timestamp']
    ensure
      File.delete(site.filename)
    end
  end

end
