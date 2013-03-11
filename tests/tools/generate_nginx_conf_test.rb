require 'minitest/unit'
require 'minitest/autorun'
require 'open3'

class GenerateNginxConfTest < MiniTest::Unit::TestCase
  def test_can_generate_nginx_vhost_given_hostname
    server_declaration_contents = generate_nginx_config('http://www.bar.com', 'foo', 'www.foo.com')

    assert_match %r{server_name\s+www.foo.com\s+aka.foo.com;}, server_declaration_contents
    assert_match %r{root\s+/var/apps/redirector/static/foo;}, server_declaration_contents
    assert_match %r{include\s+/var/apps/redirector/common/settings.conf;}, server_declaration_contents
    assert_match %r{include\s+/var/apps/redirector/common/status_pages.conf;}, server_declaration_contents
    assert_match %r{include\s+/var/apps/redirector/maps/foo/location.conf;}, server_declaration_contents
    assert_match %r{location = /\s*{ return 301 http://www.bar.com; }}, server_declaration_contents
  end

  def test_can_generate_nginx_vhost_aka_generated_for_each_www
    server_declaration_contents = generate_nginx_config('http://www.bar.com', 'foo', 'www.foo.com', 'www.bar.com')

    assert_match %r{server_name\s+www.foo.com\s+aka.foo.com\s+www.bar.com\s+aka.bar.com;}, server_declaration_contents
  end

  def test_can_generate_nginx_vhost_aka_generated_for_non_www_host
    server_declaration_contents = generate_nginx_config('http://www.bar.com', 'foo', 'foo.com')

    assert_match %r{server_name\s+foo.com\s+aka-foo.com;}, server_declaration_contents
  end

  def parse_server_declaration(output)
    %r{\bserver\s+\{(.*)\}}m.match(output)[1]
  end

  def generate_nginx_config(homepage, site, *aliases)
    cmd = "tools/generate_nginx_conf.sh --homepage #{homepage} --site #{site} #{aliases.join(' ')}"
    stdout, stderr, status = Open3.capture3(cmd)
    assert_equal 0, status.exitstatus
    parse_server_declaration(stdout)
  end
end
