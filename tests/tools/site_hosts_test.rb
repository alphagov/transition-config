require 'minitest/unit'
require 'minitest/autorun'
require 'tempfile'
require 'open3'

class SiteHostsTest < MiniTest::Unit::TestCase
  def test_simple_mappings
    exitstatus, lines = site_hosts('sites')
    assert_equal 0, exitstatus
    assert_equal 8, lines.length

    assert_equal "alias1.one.local", lines[0]
    assert_equal "alias1.paths.local", lines[1]
    assert_equal "alias1.two.local", lines[2]
    assert_equal "alias2.one.local", lines[3]
    assert_equal "alias2.two.local", lines[4]
    assert_equal "one.local", lines[5]
    assert_equal "paths.local", lines[6]
    assert_equal "two.local", lines[7]
  end

  #
  #  helper functions
  #
  def site_hosts(sites)
    cmd = "tools/site_hosts.sh --sites " << fixture_file(sites)
    stdout, stderr, status = Open3.capture3(cmd, stdin_data: '')
    if status.exitstatus != 0
      puts stderr
    end
    return status.exitstatus, stdout.split("\n")
  end

  def fixture_file(filename)
    File.dirname(__FILE__) + "/../fixtures/" + filename
  end
end
