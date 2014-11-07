#!/usr/bin/env ruby
require_relative '../../test_helper'

require 'minitest/unit'
require 'minitest/autorun'
require 'redirector/hosts'

class RedirectorHostsTest < MiniTest::Unit::TestCase
  include FilenameHelpers

  def test_files_raises_error_when_no_files
    assert_raises(RuntimeError) do
      Redirector::Hosts.files(relative_to_tests('fixtures/nosites/*.yml'))
    end
  end

  def test_files_returns_correct_number_of_filenames_when_files_exist
    files = Redirector::Hosts.files(relative_to_tests('fixtures/sites/*.yml'))
    assert_equal 3, files.size
  end

  def test_hosts_to_site_abbrs_when_a_host_appears_twice
    hosts_to_site_abbrs = Redirector::Hosts.hosts_to_site_abbrs(relative_to_tests('fixtures/duplicate_hosts_sites/*.yml'))
    expected_value = {
      'one.local'          => ['one'],
      'alias1.one.local'   => ['one'],
      'alias2.one.local'   => ['one'],
      'two.local'          => ['one', 'two'],
    }
    assert_equal expected_value, hosts_to_site_abbrs
  end

  def test_validate_unique_when_no_duplicates_exist
    # no error is raised
    Redirector::Hosts.validate_unique_and_lowercase!(relative_to_tests('fixtures/sites/*.yml'))
  end

  def test_validate_unique_when_duplicate_hosts_exist
    assert_raises(Redirector::DuplicateHostsException) do
      Redirector::Hosts.validate_unique_and_lowercase!(relative_to_tests('fixtures/duplicate_hosts_sites/*.yml'))
    end
  end

  def test_validate_lowercase_when_no_uppercase_hosts_exist
    # no error is raised
    Redirector::Hosts.validate_unique_and_lowercase!(relative_to_tests('fixtures/sites/*.yml'))
  end

  def test_validate_lowercase_when_uppercase_hosts_exist
    assert_raises(Redirector::UppercaseHostsException) do
      Redirector::Hosts.validate_unique_and_lowercase!(relative_to_tests('fixtures/uppercase_hosts_sites/*.yml'))
    end
  end
end
