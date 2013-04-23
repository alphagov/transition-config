package Mappings::LocationConfig;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;

    my $config_or_error_type = 'location';
    my $suggested_link_type;
    my $suggested_link;
    my $archive_link;
    my $config;

    my $path = $self->{'old_url_parts'}{'path'};
    my $location_key = $self->get_location_key($path);

    my $duplicate_entry_key  = $location_key;

    if ( defined $self->{'duplicates'}{$duplicate_entry_key} ) {
        $config_or_error_type = 'duplicate_entry_error';
        $config = "$self->{'old_url'}\n";
    }
    elsif ( '418' eq $self->{'status'} ) {
        $config = "location ~* ^${location_key}\$ { return 418; }\n";
    }
    elsif ( '410' eq $self->{'status'} ) {
        $config = "location ~* ^${location_key}\$ { return 410; }\n";
        $suggested_link_type = 'location_suggested_link';
        $suggested_link = $self->get_suggested_link( $self->normalise($path), 0 );
        $archive_link = $self->get_archive_link( $location_key );
    }
    elsif ( '301' eq $self->{'status'} ) {
        $config = "location ~* ^${location_key}\$ { return 301 $self->{'new_url'}; }\n";
    }

    $self->{'duplicates'}{$duplicate_entry_key} = 1;
 
    return(
        $self->{'old_url_parts'}{'host'},
        $config_or_error_type,
        $config,
        $suggested_link_type,
        $suggested_link,
        $archive_link
    );
}

sub get_location_key {
    my $self = shift;
    my $path = shift;
    return $self->normalise($path);
}

sub normalise {
    my $self = shift;
    my $path = shift;

    # remove %-encoding in source mappings for nginx
    # changing %-encoding back into real characters - why?
    $path =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;

    # escape characters with regexp meaning
    # do need to do this - where should we do this?
    # should also do this for map config
    $path =~ s{\(}{\\(}g;
    $path =~ s{\)}{\\)}g;
    $path =~ s{\.}{\\.}g;
    $path =~ s{\*}{\\*}g;

    # escape charaters with nginx config meaning
    $path =~ s{ }{\\ }g;
    $path =~ s{\t}{\\\t}g;
    $path =~ s{;}{\\;}g;

    # add optional trailing slash
    $path = $path . "/?";

    return $path;
}

1;
