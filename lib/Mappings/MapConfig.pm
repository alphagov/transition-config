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

    my $map_key = $self->get_map_key( $self->{'old_url_parts'} );

    if ( !defined $map_key ) {
        $config_or_error_type = 'no_map_key_error';
        $config_line = "$self->{'old_url'}\n";
    }

    else {
        if ( defined $self->{'duplicates'}{$map_key} ) {
            $config_or_error_type = 'duplicate_entry_error';
            $config_line = $self->{'old_url'} . "\n";
        }
        elsif ( '418' eq $self->{'status'} ) {
            $config_or_error_type = 'awaiting_content_map';
            $config_line = "~*${map_key} 418;\n";
        }
        elsif ( '410' eq $self->{'status'} ) {
            $config_or_error_type = 'gone_map';
            $config_line = "~*${map_key} 410;\n";
            $suggested_link_type = 'suggested_link_map';
            $suggested_link = $self->get_suggested_link($map_key, 1);
            $archive_link = $self->get_archive_link($map_key);
        }
        elsif ( '301' eq $self->{'status'} ) {
            $config_or_error_type   = 'redirect_map';
            $config_line = "~*${map_key} $self->{'new_url'};\n";
        }
        $self->{'duplicates'}{$map_key} = 1;
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
sub get_map_key {
    my $self         = shift;
    my $parts        = shift;

    my $query_string = $parts->{'query'};

    return $query_string;
}

1;
