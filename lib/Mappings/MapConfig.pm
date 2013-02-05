package Mappings::MapConfig;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;
    
    my $config_or_error_type;
    my $suggested_links_type;
    my $config_line;
    my $suggested_links;
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
            $suggested_links_type = 'suggested_links_map';
            $suggested_links = $self->get_suggested_link($map_key, 1);
            $archive_link = $self->get_archive_link($map_key);
        }
        elsif ( '301' eq $self->{'status'} ) {
            if ( length $self->{'new_url'}) {
                $config_or_error_type   = 'redirect_map';
                $config_line = "~${map_key} $self->{'new_url'};\n";
            } 
            else {
                $config_or_error_type = 'no_destination_error';
                $config_line = "$self->{'old_url'}\n";
            }
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
        $suggested_links_type,
        $suggested_links,
        $archive_link
    );
   
    
}
sub get_suggested_link {
    my $self   = shift;
    my $lookup = shift;
    my $is_map = shift;
    
    return unless defined $self->{'suggested'} && length $self->{'suggested'};
    
    my $links;
    foreach my $line ( split /\n/, $self->{'suggested'} ) {
        $line = $self->escape_characters($line);
        
        my( $url, $text ) = split / /, $line, 2;
        $text = $self->presentable_url($url)
            unless defined $text;
        $links .= "<a href='${url}'>${text}</a>";
        
        # we only ever use the first link
        last;
    }
    
    return "\$query_suggested_links['${lookup}'] = \"${links}\";\n"
        if defined $is_map;
    return "\$location_suggested_links['${lookup}'] = \"${links}\";\n";
}

1;
