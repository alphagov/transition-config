require 'minitest/unit'
require 'minitest/autorun'
require 'tempfile'
require 'open3'

class ValidateMappingsTest < MiniTest::Unit::TestCase
  def test_simple_mappings
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://www.gov.uk/,301",
      "http://example.com/2,,410"
      ], hosts: "example.com" )
    assert_equal 0, exitstatus
  end

  def test_bounce_wrong_columns
    exitstatus, lines = validate_mappings([
      "New Url,Old Url,Status",
      "https://example.com/1,,410"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /incorrect column names/, lines[1]
  end

  def test_detect_duplicates
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://www.gov.uk,301",
      "http://example.com/1,,410"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /line 3 is a duplicate of line 2/, lines[1]
  end

  def test_detect_301_duplicates
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://www.gov.uk,301",
      "http://example.com/1,https://www.gov.uk,301"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /line 3 is a duplicate of line 2/, lines[1]
  end

  def test_detect_410_duplicates
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,,410",
      "http://example.com/1,,410"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /line 3 is a duplicate of line 2/, lines[1]
  end

  def test_bounce_missing_status
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://www.gov.uk/,"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /invalid Status .* line 2/, lines[1]
  end

  def test_bounce_404_status
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://www.gov.uk/,404",
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /invalid Status \[404\] .* line 2/, lines[1]
  end

  def test_bounce_missing_status
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://www.gov.uk/,"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /invalid Status .* line 2/, lines[1]
  end

  def test_bounce_new_url_not_in_whitelist
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,https://whatfettle.com/,301"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /not in whitelist/, lines[1]
  end

  def test_bounce_old_url_not_canonical_uppercase
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://EXAMPLE.COM/1,https://whatfettle.com/,301"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /not canonical/, lines[1]
  end

  def test_bounce_old_url_not_canonical_https
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "https://example.com/1,https://whatfettle.com/,301"
      ], hosts: "example.com" )
    refute_equal 0, exitstatus
    assert_match /not canonical/, lines[1]
  end

  def test_bounce_old_url_not_in_hosts
    exitstatus, lines = validate_mappings([
      "Old Url,New Url,Status",
      "http://example.com/1,,410",
      "http://ok.example.com/1,,410",
      "http://fail.example.com/1,,410"
      ], hosts: "example.com ok.example.com" )
    refute_equal 0, exitstatus
    assert_match /host not/, lines[1]
  end


  #
  #  helper functions
  #
  def validate_mappings(stdin, args = {})
    stdin = [*stdin].join("\n")
    cmd = "prove tools/validate_mappings.pl :: "
    cmd << " --blacklist " + fixture_file("blacklist.txt")
    cmd << " --whitelist " + fixture_file("whitelist.txt")
    if args[:hosts]
      cmd << " --hosts '#{args[:hosts]}'"
    end
    if args[:query_string]
      cmd << " --query-string #{args[:query_string]}"
    end
    tmp = Tempfile.new('validate_mappings')
    tmp << stdin
    tmp.close
    cmd << " " + tmp.path
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: '')
    return status.exitstatus, stderr.split("\n")
  end

  def fixture_file(filename)
    File.dirname(__FILE__) + "/../fixtures/" + filename
  end
end
