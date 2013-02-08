package Mappings::Directgov;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;
    
    return $self->dg_location_config();
}

sub dg_location_config {
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
    elsif ( '410' eq $self->{'status'} ) {
        $config = "location ~* ^/en/(.*/)?$location_key\$ { return 410; }\n";
        $suggested_link_type = 'location_suggested_link';
        $suggested_link = $self->get_suggested_link( $location_key, 0 );
        $archive_link = $self->get_archive_link( $location_key, 0 );
    }
    elsif ( '301' eq $self->{'status'} ) {
        $config = "location ~* ^/en/(.*/)?$location_key\$ { return 301 $self->{'new_url'}; }\n";
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
    $self->dg_number($path);
}
sub dg_number {
    my $self = shift;
    my $path = shift;
    
    my $lc_path = lc $path;

    if ( $lc_path =~ m{^/en/} && $lc_path =~ m{/(dg_\d+)$} ) {
        return $1;
    }
    return;
}


1;