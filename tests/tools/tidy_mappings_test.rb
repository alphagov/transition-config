require 'minitest/unit'
require 'minitest/autorun'
require 'open3'

class TidyMappingsTest < MiniTest::Unit::TestCase
  def test_identical_mappings_are_skipped
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/1,http://foo/1,301"
      ])
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_301_replaces_a_410_with_the_same_old_url
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,,410",
      "http://example.com/1,http://foo/1,301",
      ])
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_410_is_skipped_where_a_301_exists_with_the_same_old_url
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/1,,410",
      ])
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_duplicate_301s_with_the_same_old_url_but_different_new_urls_are_skipped
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://snark.com,301",
      "http://example.com/1,http://snork.com,301",
      ])
    lines = stdout.split("\n")
    assert_equal 3, lines.size
    assert_equal "http://example.com/1,http://snark.com,301", lines[1]
    assert_equal "http://example.com/1,http://snork.com,301", lines[2]
  end

  def test_duplicate_301s_with_the_same_old_url_but_different_new_urls_are_skipped
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://snark.com,301",
      "http://example.com/1,http://snork.com,301",
      ])
    lines = stdout.split("\n")
    assert_equal 3, lines.size
    assert_equal "http://example.com/1,http://snark.com,301", lines[1]
    assert_equal "http://example.com/1,http://snork.com,301", lines[2]
  end

  def test_blacklisted_paths_may_not_be_redirected
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/,http://snark.com,301",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/robots.txt,http://foo/robots,301",
      ], blacklist: fixture_file("blacklist.txt"))
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_additional_csv_fields_retained_in_output
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://snark.com,301,extra,stuff",
      ])
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://snark.com,301,extra,stuff", lines[1]
  end

  def test_trump_causes_later_mappings_to_win
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1,http://foo/1,301",
      "http://example.com/1,,410"
      ], trump: true)
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,,410", lines[1]
  end

  def test_query_strings_are_removed_from_old_url_by_default
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1?foo=bar,http://foo/1,301",
      ])
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1,http://foo/1,301", lines[1]
  end

  def test_query_string_option_retains_query_strings_in_old_urls
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1?foo=bar,http://foo/1,301",
      ], query_string: '-')
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1?foo=bar,http://foo/1,301", lines[1]
  end

  def test_query_string_option_whitelists_parameters_in_old_urls
    stdout = tidy_mappings([
      "Old Url,New Url,Status,Stuff",
      "http://example.com/1?foo=bar&token=99&snark=snork&id=34,http://foo/1,301",
      ], query_string: 'id:token')
    lines = stdout.split("\n")
    assert_equal 2, lines.size
    assert_equal "http://example.com/1?id=34&token=99,http://foo/1,301", lines[1]
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
    if args[:trump]
      cmd << " --trump"
    end
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: stdin)
    assert_equal 0, status.exitstatus
    stdout
  end

  def fixture_file(filename)
    File.dirname(__FILE__) + "/../fixtures/" + filename
  end
end
