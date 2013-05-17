#!/usr/bin/env ruby

require 'minitest/unit'
require 'minitest/autorun'
require 'tempfile'
require 'open3'

class GenerateNginxConfTest < MiniTest::Unit::TestCase
  def test_can_generate_nginx_vhost_given_hostname
    server_declaration = generate_nginx_config([
        'site: foo',
        'host: www.example.com',
        'redirection_date: 13th December 2012',
        'tna_timestamp: 20120816224015',
        'title: Example&#39;s Office',
        'furl: www.gov.uk/foo',
        'homepage: http://www.bar.com'
        ])

    assert_match %r{server_name[^;]*\bwww.example.com\b}, server_declaration
    assert_match %r{server_name[^;]*\baka.example.com\b}, server_declaration
    assert_match %r{root\s+/var/apps/redirector/static/foo;}, server_declaration
    assert_match %r{include\s+/var/apps/redirector/common/settings.conf;}, server_declaration
    assert_match %r{include\s+/var/apps/redirector/common/status_pages.conf;}, server_declaration
    assert_match %r{include\s+/var/apps/redirector/maps/foo/www.example.com.conf;}, server_declaration
    assert_match %r{location = /\s*{ return 301 http://www.bar.com; }}, server_declaration
    assert_match %r{try_files \$uri \$uri.html =404;}, server_declaration
  end

  def test_multiple_aliases
    server_declaration = generate_nginx_config([
        'site: foo',
        'host: www.example.com',
        'homepage: http://www.bar.com',
        'aliases:',
        '  - www.foo.com',
        '  - bar.com'
        ])

    assert_match %r{server_name[^;]*\bwww.example.com\b}, server_declaration
    assert_match %r{server_name[^;]*\baka.example.com\b}, server_declaration
    assert_match %r{server_name[^;]*\bbar.com\b}, server_declaration
    assert_match %r{server_name[^;]*\baka-bar.com\b}, server_declaration
    assert_match %r{server_name[^;]*\bfoo.redirector.dev.alphagov.co.uk\b}, server_declaration
    assert_match %r{server_name[^;]*\bfoo.redirector.preview.alphagov.co.uk\b}, server_declaration
    assert_match %r{server_name[^;]*\bfoo.redirector.production.alphagov.co.uk\b}, server_declaration
  end

  def test_locations
    server_declaration = generate_nginx_config([
        'site: foo',
        'host: www.example.com',
        'homepage: http://www.bar.com',
        'locations:',
        '  - path: /some/path',
        '    operation: ^~',
        '    status: 301',
        '    new_url: http://new.example.com/another/path/root',
        ])

    assert_match %r{location \^~ /some/path \{ return 301 http://new.example.com/another/path/root; \}}, server_declaration
  end

  def test_global_410
    server_declaration = generate_nginx_config([
        'site: foo',
        'host: www.example.com',
        'homepage: http://www.bar.com',
        'global: 410'
        ])

    assert_match %r{try_files \$uri \$uri.html =410;}, server_declaration
  end

  def test_global_301
    server_declaration = generate_nginx_config([
        'site: foo',
        'host: www.example.com',
        'homepage: http://www.bar.com',
        'global: 301 https://www.example.com/foo'
        ])

    assert_match %r{try_files \$uri \$uri.html =399;}, server_declaration
    assert_match %r{error_page 399 =301 https://www.example.com/foo;}, server_declaration
  end


  def parse_server_declaration(output)
    %r{\bserver\s+\{(.*)\}}m.match(output)[1]
  end

  def generate_nginx_config(stdin)
    tmp = Tempfile.new('nginx_yml')
    tmp << "---\n"
    tmp << [*stdin].join("\n")
    tmp << "\n---\n"
    tmp.close
    cmd = "bin/erb.rb -y #{tmp.path} templates/nginx.erb"
    stdout, stderr, status = Open3.capture3(cmd)
    if status.exitstatus != 0
      puts stderr
    end
    assert_equal 0, status.exitstatus
    parse_server_declaration(stdout)
  end
end
