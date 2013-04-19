#!/usr/bin/env ruby
require 'minitest/unit'
require 'minitest/autorun'
require 'open3'

class TidyMappingsTest < MiniTest::Unit::TestCase
  def test_default_410_status_for_a_status_of_TNA
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,,TNA"
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,,410", lines[1]
  end

  def test_default_410_status_for_a_missing_new_url
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,,",
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,,410", lines[1]
  end

  def test_blank_new_url_for_a_410
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo.com,410",
      "http://example.com/2,http://foo.com,TNA",
      ])
    assert_equal 3, lines.size
    assert_equal "http://example.com/1,,410", lines[1]
    assert_equal "http://example.com/2,,410", lines[2]
  end

  def test_default_301_status_with_a_new_url
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,",
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_identical_mappings_are_skipped
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/1,http://foo/1,301"
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_301_replaces_a_410_with_the_same_old_url
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,,410",
      "http://example.com/1,http://foo/1,301",
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_410_is_skipped_where_a_301_exists_with_the_same_old_url
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/1,,410",
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_duplicate_301s_with_the_same_old_url_but_different_new_urls_are_skipped
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://snark.com,301",
      "http://example.com/1,http://snork.com,301",
      ])
    assert_equal 3, lines.size
    assert_equal "http://example.com/1,http://snark.com,301", lines[1]
    assert_equal "http://example.com/1,http://snork.com,301", lines[2]
  end

  def test_duplicate_301s_with_the_same_old_url_but_different_new_urls_are_skipped
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://snark.com,301",
      "http://example.com/1,http://snork.com,301",
      ])
    assert_equal 3, lines.size
    assert_equal "http://example.com/1,http://snark.com,301", lines[1]
    assert_equal "http://example.com/1,http://snork.com,301", lines[2]
  end

  def test_blacklisted_paths_may_not_be_redirected
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/,http://snark.com,301",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/robots.txt,http://foo/robots,301",
      ], blacklist: fixture_file("blacklist.txt"))
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_additional_csv_fields_retained_in_output
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://snark.com,301,extra,stuff",
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://snark.com,301,extra,stuff", lines[1]
  end

  def test_trump_causes_later_mappings_to_win
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/1,,410"
      ], trump: true)
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,,410", lines[1]
  end

  def test_query_strings_are_removed_from_old_url_by_default
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1?foo=bar,http://foo/1,301",
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_query_string_option_retains_query_strings_in_old_urls
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1?foo=bar,http://foo/1,301",
      ], query_string: '-')
    assert_equal 2, lines.size
    assert_equal "http://example.com/1?foo=bar,http://foo/1,301", lines[1]
  end

  def test_query_string_option_whitelists_parameters_in_old_urls
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1?foo=bar&token=99&snark=snork&id=34,http://foo/1,301",
      ], query_string: 'id:token')
    assert_equal 2, lines.size
    assert_equal "http://example.com/1?id=34&token=99,http://foo/1,301", lines[1]
  end

  def test_query_string_unique_across_file
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/foo?id=one,http://foo/1,301",
      "http://example.com/bar?id=bar,http://foo/2,301",
      ], query_string: 'id:token')
    assert_equal 3, lines.size
    assert_equal "http://example.com/bar?id=bar,http://example.com/foo?id=1,301", lines[1]
    assert_equal "http://example.com/bar?id=bar,http://example.com/foo?id=2,301", lines[2]
  end

  def test_query_string_unique_across_file
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/foo?id=one,http://foo/1,301",
      "http://example.com/bar?id=one,http://foo/2,301",
      ], query_string: 'id:token', trump: true)
    assert_equal 2, lines.size
    assert_equal "http://example.com/bar?id=one,http://foo/2,301", lines[1]
  end

  def test_new_urls_which_are_a_known_host_homepage_are_expanded_using_known
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://www.example.com/furl,301",
      "http://example.com/2,http://www.example.com/,301",
      ], known: fixture_file("known.csv"))
    assert_equal 3, lines.size
    assert_equal "http://example.com/1,https://www.example.com/expanded/furl,301", lines[1]
    assert_equal "http://example.com/2,https://www.example.com/expanded/homepage,301", lines[2]
  end

  def test_new_url_normalised
    lines = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://exmaple.com/you're_dangerous,301"
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://exmaple.com/you%27re_dangerous,301", lines[1]
  end


  #
  #  helper functions
  #
  def tidy_mappings(stdin, args = {})
    stdin = [*stdin].join("\n")
    cmd = "tools/tidy_mappings.pl"
    if args[:blacklist]
      cmd << " --blacklist #{args[:blacklist]}"
    end
    if args[:query_string]
      cmd << " --query-string #{args[:query_string]}"
    end
    if args[:known]
      cmd << " --known #{args[:known]}"
    end
    if args[:trump]
      cmd << " --trump"
    end
    stdout, @stderr, status = Open3.capture3(cmd, stdin_data: stdin)
    if status.exitstatus != 0
      puts stderr
    end
    assert_equal 0, status.exitstatus
    stdout.split("\n")
  end

  def fixture_file(filename)
    File.dirname(__FILE__) + "/../fixtures/" + filename
  end
end
