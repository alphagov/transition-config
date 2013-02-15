require 'minitest/autorun'

require_relative '../mapping_fetcher'

class TestDaisyChainRedirector < MiniTest::Unit::TestCase
  class Reporter
    attr :found_circular_dependencies

    def initialize
      @found_circular_dependencies = []
    end

    def circular_dependency(url, row)
      @found_circular_dependencies << [url, row]
    end
  end

  def setup
    @reporter = Reporter.new
    @fetcher = MappingFetcher.new(@reporter)
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

  def test_follows_redirect_more_than_one_step
    assert_redirects [
      {'old url' => 'http://example.com/old', 'new url' => 'http://example.com/old-middle'},
      {'old url' => 'http://example.com/old-middle', 'new url' => 'http://example.com/old-target'},
      {'old url' => 'http://example.com/old-target', 'new url' => 'https://gov.uk/new'}
    ], to: [
      {'old url' => 'http://example.com/old', 'new url' => 'https://gov.uk/new'},
      {'old url' => 'http://example.com/old-middle', 'new url' => 'https://gov.uk/new'},
      {'old url' => 'http://example.com/old-target', 'new url' => 'https://gov.uk/new'}
    ]
  end

  def test_does_not_follow_circular_redirects
    assert_redirects [
      {'old url' => 'http://example.com/old', 'new url' => 'http://example.com/old-target'},
      {'old url' => 'http://example.com/old-target', 'new url' => 'http://example.com/old'}
    ], to: [
      {'old url' => 'http://example.com/old', 'new url' => 'http://example.com/old-target'},
      {'old url' => 'http://example.com/old-target', 'new url' => 'http://example.com/old'}
    ]

    assert_equal 'http://example.com/old-target', @reporter.found_circular_dependencies[0].first
    assert_equal 'http://example.com/old', @reporter.found_circular_dependencies[1].first
  end
end
