#!/usr/bin/env perl

use strict;
use Text::CSV;

my $input = shift or die "Usage: piplinks_map_maker.pl <piplinks csv file>\n";

my $csv = Text::CSV->new( { binary => 1 } )
    or die "Cannot use CSV: ".Text::CSV->error_diag();

open( my $fh, "<", $input )
    or die "$input: $!";

my $names = $csv->getline( $fh );
$csv->column_names( @$names );

my %authority;
my %licence;
my %interaction;
my @tests;
my $verbose = 0;

while ( my $row = $csv->getline_hr( $fh ) ) {
    my $agency_id     = $row->{'AgencyId'};
    my $authority     = $row->{'AuthoritySlug'};
    my $licence_slug  = fix_slug( $row->{'LicenceSlug'} );
    my $service_id    = $row->{'ServiceId'};
    my $interact_slug = fix_slug( $row->{'InteractionSlug'} );

    if ( defined $authority{$agency_id} ) {
        die "die unless $authority{$agency_id} eq $authority"
            unless $authority{$agency_id} eq $authority;
    }
    else {
        $authority{$agency_id} = $authority;
    }

    $service_id =~ m{^(\d+)(\d\d\d\d)$};
    my $licence = $1;
    my $interaction = $2;

    if ( defined $licence{$licence} ) {
        die "die unless $licence{$licence} eq $licence_slug"
            unless $licence{$licence} eq $licence_slug;
    }
    else {
        $licence{$licence} = $licence_slug;
    }

    if ( defined $interaction{$interaction} ) {
        die "die unless $interaction{$interaction} eq $interact_slug"
            unless $interaction{$interaction} eq $interact_slug;
    }
    else {
        $interaction{$interaction} = $interact_slug;
    }

    push @tests, {
        old => sprintf( 'http://www.businesslink.gov.uk/bdotg/action/piplink?agency_id=%d&service_id=%d',
                            $agency_id, $service_id ),
        new => sprintf( 'https://www.gov.uk/apply-for-a-licence/%s/%s/%s',
                            $licence_slug, $authority, $interact_slug ),
    };
}

output_nginx_maps();
exit;


sub fix_slug {
    my $slug = shift;

    if ($verbose) {
        say STDERR "bad slug $slug" if $slug =~ m{[^a-z0-9-]}
    }

    $slug =~ s{ }{-}g;
    $slug =~ s{&}{and}g;
    $slug =~ s{'}{}g;
    $slug =~ s{[^a-z0-9-]}{-}g;
    $slug =~ s{-+}{-}g;
    $slug =~ s{-+$}{}g;
    $slug =~ s{^-+}{}g;

    # "special" case
    $slug =~ s{sex-establishment-sex-cinema}{sex-establishment---sex-cinema};
    $slug =~ s{domestic-energy-assessor-existing-buildings}{domestic-energy-assessor---existing-buildings};
    $slug =~ s{registration-carrier-broker-of-controlled-waste}{registration-carrier---broker-of-controlled-waste};

    return $slug;
}

sub output_nginx_maps {
    open(my $nginx_maps, '>&', \*STDOUT);

    say {$nginx_maps} 'map $query_string $map_authority {';
    foreach my $auth ( sort { $b <=> $a } keys %authority ) {
        say {$nginx_maps} "    ~agency_id=$auth\\b $authority{$auth};";
    }
    say {$nginx_maps} '}';
    say {$nginx_maps} '';
    say {$nginx_maps} 'map $query_string $map_licence {';
    foreach my $licence ( sort { $b <=> $a } keys %licence ) {
        say {$nginx_maps} "    ~service_id=$licence $licence{$licence};";
    }
    say {$nginx_maps} '}';
    say {$nginx_maps} '';
    say {$nginx_maps} 'map $query_string $map_interaction {';
    foreach my $interaction ( sort { $b <=> $a } keys %interaction ) {
        say {$nginx_maps} "    ~service_id=\\d+$interaction\\b $interaction{$interaction};";
    }
    say {$nginx_maps} '}';
}
