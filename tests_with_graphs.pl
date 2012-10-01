#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;

use File::Basename;
use File::Next;
use Getopt::Long    qw( :config bundling );
use Net::Statsd;
use TAP::Harness;
use Text::Intermixed;

use constant OPTIONS => qw(
      report-output=s
         graph-base=s
       graph-number=s@
    report-template=s
              tests=s
            preview
         production
);
use constant REQUIRED_OPTIONS => qw( tests graph-base );



my %option          = get_options_or_exit();
my $tests_directory = $option{'tests'};
my $graph_name_base = $option{'graph-base'};

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
my $total_tests_run = 0;
my $total_tests_passed = 0;

foreach my $graph_number ( @{ $option{'graph-number'} } ) {
    $graph_number =~ m{(.*)=(\d+)};
    $graph_numbers{$1} = $2;
}

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
    
    

    $total_tests_run += $tests_ran;
    $total_tests_passed += $passed;

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

say '';
$graph_numbers{"${graph_name_base}.total"}  = $total_tests_run;
$graph_numbers{"${graph_name_base}.passed"} = $total_tests_passed;
    
foreach my $graph ( sort keys %graph_numbers ) {
    say "$graph = $graph_numbers{$graph}";
    Net::Statsd::gauge( $graph, $graph_numbers{$graph} )
        if ! defined $option{'preview'};
}

if ( defined $option{'report-output'} ) {
    my $template = do {
            local $/;
            open my $handle, '<', $option{'report-template'}
                or die "Cannot open $option{'report-template'}: $!";
            <$handle>;
        };
    open my $report_handle, '>', $option{'report-output'}
        or die "Cannot open $option{'report-output'}: $!";
    
    my( $output, $errors ) = render_intermixed(
        $template,
        {
            graph_numbers => \%graph_numbers,
            harness       => $aggregate,
        }
    );
    
    print {$report_handle} $output;
    print STDERR $errors;
}

my $tests_considered_a_fail = 0;
$tests_considered_a_fail = 1
    if ( $total_tests_passed/$total_tests_run ) < 0.7;

exit $tests_considered_a_fail;



sub get_options_or_exit {
    my %getopts = @_;
    
    my $known = GetOptions( \%getopts, OPTIONS );
    my $usage = ! $known || $getopts{'help'};
    
    foreach my $key ( REQUIRED_OPTIONS ) {
        $usage = 1
            unless defined $getopts{ $key };
    }
    
    pod2usage() if $usage;
    
    return %getopts;
}

__END__

=head1 NAME

B<tests_with_graphs.pl> - register results of tests with statsd

=head1 SYNOPSIS

B<tests_with_graphs.pl> --tests <dir> --graph-base <string>
    
=head1 OPTIONS

=over

=item --tests <dir>

Run all tests found under <dir>. Required.

=item --graph-base <string>

Base name for graphs in statsd/graphite. Required.

=item --report-template <file>

Use <file> as a template to produce a report.

=item --report-output <file>

Output the expanded report template in <file>.

=item --graph-number "example=54"

Add numbers to graphs for the report that aren't calculated by running
the tests. Can be used multiple times.
