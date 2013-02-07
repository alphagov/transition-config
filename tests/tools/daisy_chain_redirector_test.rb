require 'minitest/autorun'

require 'tools/mapping_fetcher'

class TestDaisyChainRedirector < MiniTest::Unit::TestCase
  def setup
    @fetcher = MappingFetcher.new("decc")
  end

  def assert_redirects(rows, options)
    output = @fetcher.follow_url_chains(rows).map {|x| x}
    expected = options[:to]
    output.each_with_index do |output_row, i|
      expected[i].each do |key, value|
        assert_equal value, output_row[key]
      end
    end
  end

  def test_new_url_existing_as_old_url_in_file_will_follow_redirect
    assert_redirects [
      {'old url' => 'http://example.com/old', 'new url' => 'http://example.com/old-target'},
      {'old url' => 'http://example.com/old-target', 'new url' => 'https://gov.uk/new'}
    ], to: [
      {'old url' => 'http://example.com/old', 'new url' => 'https://gov.uk/new'},
      {'old url' => 'http://example.com/old-target', 'new url' => 'https://gov.uk/new'}
    ]
  end

  def test_does_not_follow_circular_redirects

  end
end
