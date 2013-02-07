package Mappings::MapConfig;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;
    
    my $config_or_error_type;
    my $suggested_link_type;
    my $config_line;
    my $suggested_link;
    my $archive_link;
    
    my $map_key = $self->{'old_url_parts'}{'query'};
    if ( defined $map_key ) {
        if ( defined $self->{'duplicates'}{$map_key} ) {
            $config_or_error_type = 'duplicate_entry_error';
            $config_line = $self->{'old_url'} . "\n";
        }
        elsif ( '410' eq $self->{'status'} ) {
            $config_or_error_type = 'gone_map';
            $config_line = "~${map_key} 410;\n";
            $suggested_link_type = 'suggested_link_map';
            $suggested_link = $self->get_suggested_link($map_key, 1);
            $archive_link = $self->get_archive_link($map_key);
        }
        elsif ( '301' eq $self->{'status'} ) {
            $config_or_error_type   = 'redirect_map';
            $config_line = "~${map_key} $self->{'new_url'};\n";
        }
        $self->{'duplicates'}{$map_key} = 1;
    }
    else {
        $config_or_error_type = 'no_map_key_error'; 
        $config_line = "$self->{'old_url'}\n"; 
    }
    
    return(
        $self->{'old_url_parts'}{'host'},
        $config_or_error_type,
        $config_line,
        $suggested_link_type,
        $suggested_link,
        $archive_link
    );
}

1;
