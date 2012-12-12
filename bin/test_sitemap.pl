#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use Test::More;
use XML::Parser;
use URI;

my $sitemap_file    = shift;
my %valid_hostnames;

map { $valid_hostnames{$_} = 1 } @ARGV;

my @expected_tags = qw( urlset url loc );
my $xml_parser    = new XML::Parser(
        Namespaces => 1,
        Handlers => {
            Start   => \&handle_start_tag,
            End     => \&handle_end_tag,
            Char    => \&handle_non_markup,
        }
    );
my $url_in_tag;



$xml_parser->parsefile($sitemap_file, ErrorContext => 3)
    or die;

done_testing();
exit;



sub handle_start_tag {
    my $parser     = shift;
    my $tag        = shift;
    my %attributes = @_;
    
    my $depth        = $parser->depth();
    my $expected_tag = $expected_tags[$depth];
    my $namespace    = $parser->namespace($tag);
    
    is(
        $namespace,
        'http://www.sitemaps.org/schemas/sitemap/0.9',
        'namespace is correct'
    );
    is(
        $tag,
        $expected_tag,
        'tag is correct'
    );
    
    undef $url_in_tag;
}
sub handle_end_tag {
    my $parser = shift;
    my $tag    = shift;
    
    if ( 'loc' eq $tag ) {
        $url_in_tag =~ s{^ \s* (.*) \s* $}{$1}x;
        
        my $uri = URI->new($url_in_tag);
        my $hostname = $uri->host;
        
        ok(
            $uri->scheme =~ m{^ http s? $}x,
            'scheme is either http or https'
        );
        ok(
            defined $valid_hostnames{$hostname},
            "hostname $hostname is valid"
        );
    }
}
sub handle_non_markup {
    my $parser = shift;
    my $string = shift;
    
    $url_in_tag .= $string;
}
