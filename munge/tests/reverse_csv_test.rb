require 'minitest/autorun'
require 'open3'

REVERSE = File.dirname(__FILE__) + "/../reverse-csv.rb"

class TestReverseCsv < MiniTest::Unit::TestCase
  def assert_reverse_csv(input, output)
    assert_equal output, `echo "#{input}" | #{REVERSE}`.strip
  end

  def test_does_nothing_to_one_line
    assert_reverse_csv("1", "1")
  end

  def test_reverses_more_lines_preserving_header
    assert_reverse_csv("1\n2\n3", "1\n3\n2")
  end
end
