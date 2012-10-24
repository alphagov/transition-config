#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use Test::More;
use XML::Parser;
use URI;

test_file('dist/static/dg/sitemap.xml', {
	'www.direct.gov.uk' => 1
});

test_file('dist/static/bl/sitemap.xml', {
	'www.businesslink.gov.uk' => 1,
	'online.businesslink.gov.uk' => 1,
});

done_testing();

#
#  check validity of sitemap.xml
#
my $url;

sub test_file {

	my $path = shift || "sitemap.xml";

	my $parser = new XML::Parser( Namespaces => 1, 
		Handlers => {
			Start   => \&hdl_start,
			End     => \&hdl_end,
			Char    => \&hdl_char,
			Default => \&hdl_def,
		});

	$parser->{_}->{host} = shift;

	$parser->parsefile($path, ErrorContext => 3) or die;
}

# The Handlers
sub hdl_start {
	my ($p, $element, %atts) = @_;
	my $expected = qw(urlset url loc)[$p->depth()];
	my $namespace = $p->namespace($element);
	undef $url;

	ok($namespace eq 'http://www.sitemaps.org/schemas/sitemap/0.9', "namespace <" . $namespace . ">");
	ok($element eq $expected, "expected <$element>, got <$element>");
}

sub hdl_char {
	my ($p, $str) = @_;
	$url .= $str;
}
 
sub hdl_end {
	my ($p, $element) = @_;

	if ($element eq "loc") {
		$url =~ s/^\s*(.*)\s*$/$1/;

		# valid URI?
		my $uri = URI->new($url);
		ok($uri->scheme =~ /^(http|https)$/, "http/https <$url>");
		ok($p->{_}->{host}->{$uri->host}, "known host <" . $uri->host . ">");
	}
}

sub hdl_def { }
