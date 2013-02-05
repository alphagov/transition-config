package SourcesTest;

use v5.10;
use strict;
use warnings;

use Test::More;
use Text::CSV;
use HTTP::Request;
use LWP::UserAgent;
use URI;
use Carp;

sub new {
    my $class = shift;
    my $file  = shift;

    my $self = {
            input_file => $file,
        };
    bless $self, $class;

    return $self;
}

sub run_tests {
    my $self = shift;

    my $csv = Text::CSV->new({ binary => 1 })
                or die "Cannot use CSV: " . Text::CSV->error_diag();

    open( my $fh, "<", $self->{'input_file'} )
            or die "$self->{'input_file'}: $!";

    my $names = $csv->getline( $fh );
    $csv->column_names( @$names );

    while ( my $row = $csv->getline_hr( $fh ) ) {
        $self->test($row);
    }
}

sub check_url {
    my ($self, $name, $url) = @_;

    ok($url =~ m{^https?://}, "$name '${url}' should be a full URL");

    my $uri = URI->new($old_url);
    is($old_uri, $old_url, "Old Url '${old_url}' should be a valid URL");

    return $uri;
}

sub test_source_line {
    my $self = shift;
    my $row  = shift;

    my $old_url = $row->{'Old Url'} // '';
    my $new_url = $row->{'New Url'} // '';
    my $status = $row->{'Status'} // '';

    $self->check_url('Old Url', $old_url);

    if ( "301" eq $status) {
        $self->check_url('New Url', $new_url);
    } elsif ( "410" eq $status) {
        ok($new_url eq '', "unexpected New Url for 410: [$new_url] line $.");
    } elsif ( "200" eq $status) {
        ok($new_url eq '', "unexpected New Url for 200: [$new_url] line $.");
    } else {
       fail("unexpected Status code: [$status] line $.");
    }
}

1;
