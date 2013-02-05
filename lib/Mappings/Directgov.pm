package Mappings::Directgov;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;

    my $dg_number = $self->dg_number($self->{'old_url_parts'});
    if ( defined $dg_number ) {
        $self->{'dg_number'} = $dg_number;

        return $self->dg_location_config();
    }

    return $self->location_config();
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
    
    # assume mappings are closed unless otherwise stated
    my $mapping_status = 'closed';
    if ( defined $self->{'whole_tag'} && $self->{'whole_tag'} =~ m{status:(\S+)} ) {
        $mapping_status = $1;
    }
    
    my $config_or_error_type = 'location';
    my $duplicate_entry_key  = $self->{'old_url_parts'}{'path'};
    my $suggested_links_type;
    my $suggested_links;
    my $archive_link;
    my $config;
    
    if ( defined $self->{'duplicates'}{$duplicate_entry_key} ) {
        $config_or_error_type = 'duplicate_entry_error';
        $config = "$self->{'old_url'}\n";
    }
    elsif ( 'closed' eq $mapping_status ) {
        if ( '410' eq $self->{'status'} ) {
            if ( defined $self->{'whole_tag'} && $self->{'whole_tag'} =~ m{gone-welsh} ) {
                # 410 Gone Welsh (actually a 301 to the Why No Welsh page)
                $config = "location ~* ^/en/(.*/)?$self->{'dg_number'}\$ { return 301 https://www.gov.uk/cymraeg; }\n"
            }
            else {
                # 410 Gone
                $config = "location ~* ^/en/(.*/)?$self->{'dg_number'}\$ { return 410; }\n";
                $suggested_links_type = 'location_suggested_links';
                $suggested_links = $self->get_suggested_link( $self->{'dg_number'} );
                $archive_link = $self->get_archive_link( $self->{'dg_number'} );
            }
        }
        elsif ( '301' eq $self->{'status'} ) {
            # 301 Moved Permanently
            if ( length $self->{'new_url'} ) {
                $config = "location ~* ^/en/(.*/)?$self->{'dg_number'}\$ { return 301 $self->{'new_url'}; }\n";

            }
            else {
                $config_or_error_type   = 'no_destination_error';
                $config = "$self->{'old_url'}\n";
            }
        }
        elsif ( '302' eq $self->{'status'} || 'awaiting-content' eq $mapping_status ) {
            # 302 Moved Temporarily
            $config = "location ~* ^/en/(.*/)?$self->{'dg_number'}\$ { return 302 https://www.gov.uk; }\n";
        }
    }
    elsif ( 'awaiting-content' eq $mapping_status ) {
        # 302 Moved Temporarily
        $config = "location ~* ^/en/(.*/)?$self->{'dg_number'}\$ { return 302 https://www.gov.uk; }\n";
    }
    else {
        $config_or_error_type   = 'unresolved';
        $config = "$self->{'old_url'}\n";
    }
   
    $self->{'duplicates'}{$duplicate_entry_key} = 1;
        
    return(
        $self->{'old_url_parts'}{'host'},
        $config_or_error_type,
        $config,
        $suggested_links_type,
        $suggested_links,
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
    
    return "\$location_suggested_links['${location}'] = \"${links}\";\n";
}


1;