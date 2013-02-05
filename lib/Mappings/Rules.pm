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
        new_url   => $row->{'New Url'},
        status    => $row->{'Status'},
        whole_tag => $row->{'Whole Tag'},
        suggested => $row->{'Suggested Link'},
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
