#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use File::Basename;
use File::Next;
use Net::Statsd;
use TAP::Harness;



my $tests_directory = shift;
my $graph_name_base = shift;

die "Usage: tests_with_graphs.pl <directory> <graph name base>"
    unless defined $tests_directory && defined $graph_name_base;


my $find_tests = File::Next::files( $tests_directory );
my $harness    = TAP::Harness->new({
        lib       => [ 'lib' ],
        verbosity => 0,
    });
my @tests;

while ( my $path = $find_tests->() ) {
    my $file = basename $path;
    next if $file =~ m{^\.};
    
    push @tests, $path;
}

my $aggregate = $harness->runtests(@tests);
my %graph_numbers;
my $any_tests_have_failed = 0;

foreach my $test ( @tests ) {
    my $results = $aggregate->{'parser_for'}{$test};
    
    my $test_name = $test;
    $test_name =~ s{.*?(\w+)(?:\.[^\.]+)?$}{$1};
    
    my $directory = dirname $test;
    $directory =~ s{^$tests_directory/}{};
    
    my @directories = split m{/}, $directory;
    my $graph_path  = $graph_name_base;
    my $tests_ran   = $results->{'tests_run'};
    my $passed      = scalar @{ $results->{'actual_passed'} };
    
    $any_tests_have_failed = 1
        if $tests_ran > $passed;
    
    $graph_numbers{"${graph_path}.total"}  += $tests_ran;
    $graph_numbers{"${graph_path}.passed"} += $passed;
    $graph_numbers{"${graph_path}.${test_name}.total"}  += $tests_ran;
    $graph_numbers{"${graph_path}.${test_name}.passed"} += $passed;
    
    foreach my $subdir ( @directories ) {
        $graph_path .= ".${subdir}";
        
        $graph_numbers{"${graph_path}.total"}  += $tests_ran;
        $graph_numbers{"${graph_path}.passed"} += $passed;
        $graph_numbers{"${graph_path}.${test_name}.total"}  += $tests_ran;
        $graph_numbers{"${graph_path}.${test_name}.passed"} += $passed;
    }
}

say "\nRegistering graphs...";
foreach my $graph ( sort keys %graph_numbers ) {
    say "$graph = $graph_numbers{$graph}";
    Net::Statsd::gauge( $graph, $graph_numbers{$graph} );
}

exit $any_tests_have_failed;
