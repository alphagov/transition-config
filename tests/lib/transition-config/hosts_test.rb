#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../test_helper"

class TransitionConfigHostsTest < MiniTest::Unit::TestCase
  include FilenameHelpers

  def test_files_raises_error_when_no_files
    assert_raises(RuntimeError) do
      TransitionConfig::Hosts.files(relative_to_tests("fixtures/nosites/*.yml"))
    end
  end

  def test_files_returns_correct_number_of_filenames_when_files_exist
    files = TransitionConfig::Hosts.files(relative_to_tests("fixtures/sites/*.yml"))
    assert_equal 3, files.size
  end

  def test_hosts_to_site_abbrs_when_a_host_appears_twice
    hosts_to_site_abbrs = TransitionConfig::Hosts.hosts_to_site_abbrs(relative_to_tests("fixtures/duplicate_hosts_sites/*.yml"))
    expected_value = {
      "one.local" => %w[one].to_set,
      "alias1.one.local" => %w[one].to_set,
      "alias2.one.local" => %w[one].to_set,
      "two.local" => %w[one two].to_set,
    }
    assert_equal expected_value, hosts_to_site_abbrs
  end

  def test_validate_unique_when_no_duplicates_exist
    # no error is raised
    TransitionConfig::Hosts.validate!(relative_to_tests("fixtures/sites/*.yml"))
  end

  def test_validate_unique_when_duplicate_hosts_exist
    assert_raises(TransitionConfig::DuplicateHostsException) do
      TransitionConfig::Hosts.validate!(relative_to_tests("fixtures/duplicate_hosts_sites/*.yml"))
    end
  end

  def test_validate_lowercase_when_no_uppercase_hosts_exist
    # no error is raised
    TransitionConfig::Hosts.validate!(relative_to_tests("fixtures/sites/*.yml"))
  end

  def test_validate_lowercase_when_uppercase_hosts_exist
    assert_raises(TransitionConfig::UppercaseHostsException) do
      TransitionConfig::Hosts.validate!(relative_to_tests("fixtures/uppercase_hosts_sites/*.yml"))
    end
  end
end
