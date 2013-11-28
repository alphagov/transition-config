#!/usr/bin/env ruby
require_relative '../../test_helper'

require 'minitest/unit'
require 'minitest/autorun'
require 'redirector/site'
require 'gds_api/test_helpers/organisations'

class RedirectorSiteTest < MiniTest::Unit::TestCase
  include GdsApi::TestHelpers::Organisations
  include FilenameHelpers

  def setup
    @old_app_domain = ORGANISATIONS_API_ENDPOINT
    ORGANISATIONS_API_ENDPOINT.gsub! /^.*$/, 'https://whitehall-admin.production.alphagov.co.uk'
  end

  def teardown
    ORGANISATIONS_API_ENDPOINT.gsub! /^.*$/, @old_app_domain
  end

  def test_can_initialize_site_from_yml
    site = Redirector::Site.new(File.read(site_filename('ago')))
    assert_equal 'attorney-generals-office', site.whitehall_slug
    assert_equal 'ago', site.abbr
  end

  def test_can_enumerate_all_sites
    number_of_sites = Dir[redirector_path('data/sites/*.yml')].length

    assert_equal Redirector::Site.all.length, number_of_sites
  end

  def test_all_raises_error_when_no_files
    assert_raises(RuntimeError) do
      Redirector::Site.all(relative_to_tests('fixtures/nosites/*.yml'))
    end
  end

  def test_site_has_whitehall_slug
    slug = Redirector::Site.all.first.whitehall_slug
    assert_instance_of String, slug
    refute_empty slug
  end

  def test_existing_site_slug_exists_in_whitehall?
    organisations_api_has_organisations(%w(attorney-generals-office))
    ago = Redirector::Site.all.first
    assert ago.slug_exists_in_whitehall?,
           "expected #{ago.whitehall_slug} to exist in whitehall"
  end

  def test_non_existing_site_slug_does_not_exist_in_whitehall?
    organisations_api_has_organisations(%w(nothing-interesting))
    refute Redirector::Site.all.first.slug_exists_in_whitehall?,
           'expected slug "attorney-generals-office" not to exist in Mock whitehall'
  end

  def test_checks_all_slugs
    organisations_api_has_organisations(%w(attorney-generals-office paths))

    exception = assert_raises(Redirector::SlugsMissingException) do
      Redirector::Site.check_all_slugs!(relative_to_tests('fixtures/slug_check_sites/*.yml'))
    end

    refute_nil exception.missing.find {|site| site.whitehall_slug == 'non-existent-slug' }
    assert_nil exception.missing.find {|site| site.whitehall_slug == 'directgov_microsite' }
  end
end
