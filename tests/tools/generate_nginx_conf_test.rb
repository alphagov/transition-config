require 'minitest/unit'
require 'minitest/autorun'
require 'open3'

class GenerateNginxConfTest < MiniTest::Unit::TestCase
  def test_can_generate_nginx_vhost_given_hostname
    stdout, stderr, status = Open3.capture3(%{tools/generate_nginx_conf.sh --homepage "http://www.bar.com" --site foo www.foo.com})
    expected_generated_config = %q{server {
    server_name     www.foo.com
                    aka.foo.com;

    root            /var/apps/redirector/static/foo;
    include         /var/apps/redirector/common/settings.conf;
    include         /var/apps/redirector/common/status_pages.conf;
    include         /var/apps/redirector/maps/foo/location.conf;

    location = /    { return 301 http://www.bar.com; }
}
}

    assert_equal 0, status.exitstatus
    assert_equal expected_generated_config, stdout
    assert_match %r{server\s+\{\s+server_name\s+www.foo.com\s+aka.foo.com;}, stdout
    assert_match %r{root\s+/var/apps/redirector/static/foo;}, stdout
    assert_match %r{include\s+/var/apps/redirector/common/settings.conf;}, stdout
    assert_match %r{include\s+/var/apps/redirector/common/status_pages.conf;}, stdout
    assert_match %r{include\s+/var/apps/redirector/maps/foo/location.conf;}, stdout
    assert_match %r{location = /\s*{ return 301 http://www.bar.com; }}, stdout
  end
end
