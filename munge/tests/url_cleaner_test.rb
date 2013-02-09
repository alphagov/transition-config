require 'minitest/autorun'

require 'munge/mapping_fetcher'

class TestUrlCleaner < MiniTest::Unit::TestCase
  def setup
    @fetcher = MappingFetcher.new("decc")
  end

  def assert_sanitize_url(broken_url, fixed_url)
    assert_equal fixed_url, @fetcher.sanitize_url(broken_url)
  end

  def test_sanitize_url_replaces_spaces
    assert_sanitize_url "http://gov.uk/path with spaces", "http://gov.uk/path%20with%20spaces"
  end

  def test_sanitize_url_removes_trailing_spaces
    assert_sanitize_url "http://gov.uk/path with spaces ", "http://gov.uk/path%20with%20spaces"
    assert_sanitize_url "http://gov.uk/path with spaces%20", "http://gov.uk/path%20with%20spaces"
    assert_sanitize_url "http://gov.uk/path with spaces%20%20", "http://gov.uk/path%20with%20spaces"
  end

  def test_sanitize_url_replaces_rogue_escaped_amps_with_real_ones
    assert_sanitize_url "http://gov.uk/?foo&amp;bar", "http://gov.uk/?foo&bar"
  end

  def test_sanitize_url_removes_unclosed_brackets
    assert_sanitize_url "http://gov.uk/?foo(bar)", "http://gov.uk/?foo(bar)"
    assert_sanitize_url "http://gov.uk/?foobar)", "http://gov.uk/?foobar"
  end

  def test_sanitize_url_replaces_commas_with_urlencoded_verison
    assert_sanitize_url "http://gov.uk/?foo=bar,baz,quux", "http://gov.uk/?foo=bar%2Cbaz%2Cquux"
  end
end
