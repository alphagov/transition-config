package Mappings::Directgov;

use strict;
use warnings;
use base 'Mappings::LocationConfig';



sub actual_nginx_config {
    my $self = shift;
    
    return $self->location_config();
}
sub get_location_key {
    my $self = shift;
    my $path = shift;
    
    my $dg_number = $self->dg_number($path);
    my $location_key = "/en/(.*/)?$dg_number";
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