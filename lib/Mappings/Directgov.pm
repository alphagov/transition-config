package Mappings::Directgov;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;
    
    return $self->dg_location_config();
}


sub dg_number {
    my $self = shift;
    my $parts = shift;
    
    my $lc_old_url = lc $parts->{'path'};

    if ( $lc_old_url =~ m{^/en/} && $lc_old_url =~ m{/(dg_\d+)$} ) {
        return $1;
    }
    return;
}
sub dg_location_config {
    my $self = shift;
    
    my $config_or_error_type = 'location';
    my $duplicate_entry_key  = $self->{'old_url_parts'}{'path'};
    my $suggested_link_type;
    my $suggested_link;
    my $archive_link;
    my $config;
    my $dg_number = $self->dg_number($self->{'old_url_parts'});
    
    if ( defined $self->{'duplicates'}{$duplicate_entry_key} ) {
        $config_or_error_type = 'duplicate_entry_error';
        $config = "$self->{'old_url'}\n";
    }
    elsif ( '410' eq $self->{'status'} ) {
        $config = "location ~* ^/en/(.*/)?$dg_number\$ { return 410; }\n";
        $suggested_link_type = 'location_suggested_link';
        $suggested_link = $self->get_suggested_link( $dg_number );
        $archive_link = $self->get_archive_link( $dg_number );
    }
    elsif ( '301' eq $self->{'status'} ) {
        if ( length $self->{'new_url'} ) {
            $config = "location ~* ^/en/(.*/)?$dg_number\$ { return 301 $self->{'new_url'}; }\n";

        }
        else {
            $config_or_error_type   = 'no_destination_error';
            $config = "$self->{'old_url'}\n";
        }
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
sub get_suggested_link {
    my $self     = shift;
    my $location = shift;
    
    return unless defined $self->{'suggested'} && length $self->{'suggested'};
    
    # strip trailing slashes for predictable matching in 410 page code
    $location =~ s{/$}{};
    
    my $links;
    foreach my $line ( split /\n/, $self->{'suggested'} ) {
        $line = $self->escape_characters($line);
        
        my( $url, $text ) = split / +/, $line, 2;
        $text = $self->presentable_url($url)
            unless defined $text && length $text;
        $links .= "<a href='${url}'>${text}</a>";
        
        # we only ever use the first link
        last;
    }
    
    return "\$location_suggested_link['${location}'] = \"${links}\";\n";
}


1;