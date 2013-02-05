package Mappings::Rules;

use v5.10;
use strict;
use warnings;

use Mappings::Businesslink;
use Mappings::Directgov;
use Mappings::LocationConfig;
use Mappings::MapConfig;

use URI::Split  qw( uri_split uri_join );

my %SPECIAL_CASE_HOSTS = (
    'www.businesslink.gov.uk'                   => 'Businesslink',
    'www.ukwelcomes.businesslink.gov.uk'        => 'Businesslink',
    
    'www.direct.gov.uk'                         => 'Directgov',
);



sub new {
    my $class = shift;
    my $row   = shift;
    my $duplicate_key_cache = shift;
    
    return unless defined $row;

    # strip potential trailing whitespace from urls
    $row->{'New Url'} =~ s{\s+$}{};
    $row->{'Old Url'} =~ s{\s+$}{};
    
    my( $scheme, $host, $path, $query, $frag ) = uri_split $row->{'Old Url'};

    my $self = {
        old_url          => $row->{'Old Url'},
        old_url_parts    => {
            scheme => $scheme,
            host   => $host,
            path   => $path,
            query  => $query,
            frag   => $frag,
        },

        dg_number => '',
        new_url   => $row->{'New Url'},
        status    => $row->{'Status'},
        whole_tag => $row->{'Whole Tag'},
        suggested => $row->{'Suggested Links'},
        archive_link => $row->{'Archive Link'},
        
        duplicates => $duplicate_key_cache,
    };
    my $config_rule_type = get_config_rule_type( $class, $host, $path, $query );
    bless $self, $config_rule_type;
    
    return $self;
}

sub get_config_rule_type {
    my $config_rule_type = shift;
    my $host = shift;
    my $path = shift;
    my $query = shift;
    
    my $special_case_host;
    if ( defined $host && defined $SPECIAL_CASE_HOSTS{$host} ) {
        $special_case_host = $SPECIAL_CASE_HOSTS{$host};
    }

    if ( $query ) {
        if ( $special_case_host && $special_case_host eq 'Businesslink' ) {
            $config_rule_type = "Mappings::Businesslink";
        }
        else {
            $config_rule_type = "Mappings::MapConfig";
        }
    }
    else {
        # Should be: If it is a directgov host and it has a dg_number call the dg number DG config
        if ( $special_case_host && $special_case_host eq 'Directgov' && has_dg_number( $path ) ) {
            $config_rule_type = "Mappings::Directgov";
        }
        else {
            $config_rule_type = "Mappings::LocationConfig";
        }
    }
    return $config_rule_type;
}
sub has_dg_number {
    my $path = shift;
    
    my $lc_old_url = lc $path;

    if ( $lc_old_url =~ m{^/en/} && $lc_old_url =~ m{/(dg_\d+)$} ) {
        return 1;
    }
    return 0;
}
sub as_nginx_config {
    my $self = shift;
    
    # default checks for sane input
    return( 'no_host', 'no_source_url', "$self->{'new_url'}\n" )
        if !defined $self->{'old_url'} || !length $self->{'old_url'};
    
    return( $self->{'old_url_parts'}{'host'}, 'no_status', "$self->{'old_url'}\n" )
        if !defined $self->{'status'} || !length $self->{'status'};

    return $self->actual_nginx_config();
}

sub actual_nginx_config {
    my $self = shift;

    return $self->location_config();
}


sub location_config {
    my $self = shift;
    
    # assume mappings are closed unless otherwise stated
    my $mapping_status = $self->{'whole_tag'} // 'closed';
    if ( defined $self->{'whole_tag'} && $self->{'whole_tag'} =~ m{status:(\S+)} ) {
        $mapping_status = $1;
    }
    $mapping_status = lc $mapping_status;
    
    my $config_or_error_type = 'location';
    my $duplicate_entry_key  = $self->{'old_url_parts'}{'host'} . $self->{'old_url_parts'}{'path'};
    my $suggested_links_type;
    my $suggested_links;
    my $archive_link;
    my $config;
    
    # remove %-encoding in source mappings for nginx
    my $old_url = $self->{'old_url_parts'}{'path'};
    $old_url =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
    
    # escape characters with regexp meaning
    $old_url =~ s{\(}{\\(}g;
    $old_url =~ s{\)}{\\)}g;
    $old_url =~ s{\.}{\\.}g;
    $old_url =~ s{\*}{\\*}g;
    
    # escape charaters with nginx config meaning
    $old_url =~ s{ }{\\ }g;
    $old_url =~ s{\t}{\\\t}g;
    $old_url =~ s{;}{\\;}g;
    
    # strip trailing slashes, as they are added as optional in nginx
    $old_url =~ s{/$}{};
    
    # escape characters with nginx config meaning in the destination
    my $new_url = $self->{'new_url'};
    $new_url =~ s{;}{\\;}g;
    
    if ( defined $self->{'duplicates'}{$duplicate_entry_key} ) {
        $config_or_error_type = 'duplicate_entry_error';
        $config = "$self->{'old_url'}\n";
    }
    elsif ( 'closed' eq $mapping_status ) {
        if ( '410' eq $self->{'status'} ) {
            # 410 Gone
            $config = "location ~* ^${old_url}/?\$ { return 410; }\n";
            $suggested_links_type = 'location_suggested_links';
            $suggested_links = $self->get_suggested_link( $self->{'old_url_parts'}{'path'} );
            $archive_link = $self->get_archive_link( $self->{'old_url_parts'}{'path'} );
        }
        elsif ( '301' eq $self->{'status'} ) {
            # 301 Moved Permanently
            if ( length $new_url ) {
                $config = "location ~* ^${old_url}/?\$ { return 301 $new_url; }\n";
            }
            else {
                $config_or_error_type   = 'no_destination_error';
                $config = "$self->{'old_url'}\n";
            }
        } 
        elsif ( '302' eq $self->{'status'} || 'awaiting-content' eq $mapping_status ) {
            # 302 Moved Temporarily
            $config = "location ~* ^${old_url}/?\$ { return 302 https://www.gov.uk; }\n";
        }
    }
    elsif ( 'awaiting-content' eq $mapping_status ) {
        # 302 Moved Temporarily
        $config = "location ~* ^${old_url}/?\$ { return 302 https://www.gov.uk; }\n";
    }
    else {
        $config_or_error_type   = 'unresolved';
        $config = "$self->{'old_url'}\n";
    }
    # online.businesslink, businesslink and ukwelcomes should all go into the same server block
    # as www.businesslink. Special-cased for now
    if ( 'online.businesslink.gov.uk' eq $self->{'old_url_parts'}{'host'} 
        || 'www.ukwelcomes.businesslink.gov.uk' eq $self->{'old_url_parts'}{'host'} 
        || 'businesslink.gov.uk' eq $self->{'old_url_parts'}{'host'} ) {
        $self->{'old_url_parts'}{'host'} = 'www.businesslink.gov.uk';
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
sub get_archive_link {
    my $self     = shift;
    my $location = shift;
    
    return unless defined $self->{'archive_link'} && length $self->{'archive_link'};
    
    # strip trailing slashes for predictable matching in 410 page code
    $location =~ s{/$}{};
    
    return "\$archive_links['$location'] = \"$self->{'archive_link'}\";\n";
}
sub escape_characters {
    my $self   = shift;
    my $string = shift;
    
    $string =~ s{"}{''}g;
    $string =~ s{<}{&lt;}g;
    $string =~ s{>}{&gt;}g;
    
    return $string;
}
sub presentable_url {
    my $self = shift;
    my $url  = shift;
    
    $url =~ s{^https?://(?:www\.)?}{};
    $url =~ s{/$}{};
    
    return $url;
}

1;
