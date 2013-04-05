require 'minitest/unit'
require 'minitest/autorun'
require 'open3'

class EscapeCommasInUrlsTest < MiniTest::Unit::TestCase
  def test_headings_are_preserved
    lines = invoke("escape_commas_in_urls", ['Old Url,New Url,Status,Stuff'])
    assert_equal ['Old Url,New Url,Status,Stuff'], lines
  end

  def test_additional_fields_are_preserved
    lines = invoke("escape_commas_in_urls", [
      'Old Url,New Url,Status,Stuff',
      ',,,Some random stuff'
    ])
    assert_equal ',,,Some random stuff', lines[1]
  end

  def test_commas_in_old_url_are_escaped
    lines = invoke("escape_commas_in_urls", [
      'Old Url,New Url,Status,Stuff',
      '"http://example.com/1,2",,TNA'
      ])
    assert_equal 2, lines.size
    assert_equal "http://example.com/1%2C2,,TNA", lines[1]
  end

  def test_commas_in_new_url_are_escaped
    lines = invoke("escape_commas_in_urls", [
      'Old Url,New Url,Status,Stuff',
      ',"http://example.com/1,2",TNA'
      ])
    assert_equal 2, lines.size
    assert_equal ",http://example.com/1%2C2,TNA", lines[1]
  end

  #
  #  helper functions
  #
  def invoke(cmd, stdin, args = {})
    stdin = [*stdin].join("\n")
    cmd = File.dirname(__FILE__) + "/../../tools/" + cmd
    args.each do |argname, argvalue|
      cmd << " --#{argname} #{argvalue}"
    end
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: stdin)
    raise stderr unless status.exitstatus == 0
    stdout.split("\n")
  end
end