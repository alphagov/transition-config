require 'minitest/unit'
require 'minitest/autorun'
require 'open3'

class GenerateNginxConfTest < MiniTest::Unit::TestCase
  def test_can_generate_nginx_vhost_given_hostname
    stdout, stderr, status = Open3.capture3(%{tools/generate_nginx_conf.sh --homepage "http://www.bar.com" --site foo www.foo.com})

    assert_equal 0, status.exitstatus

    match = %r{\bserver\s+\{(.*)\}}m.match(stdout)
    assert match
    innards = match[1]

    assert_match %r{server_name\s+www.foo.com\s+aka.foo.com;}, innards
    assert_match %r{root\s+/var/apps/redirector/static/foo;}, innards
    assert_match %r{include\s+/var/apps/redirector/common/settings.conf;}, innards
    assert_match %r{include\s+/var/apps/redirector/common/status_pages.conf;}, innards
    assert_match %r{include\s+/var/apps/redirector/maps/foo/location.conf;}, innards
    assert_match %r{location = /\s*{ return 301 http://www.bar.com; }}, innards
  end
end
