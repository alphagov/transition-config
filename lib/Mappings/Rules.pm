package Mappings::Rules;

use v5.10;
use strict;
use warnings;

use Mappings::Businesslink;
use Mappings::LocationConfig;
use Mappings::MapConfig;

use URI::Split  qw( uri_split uri_join );

my %SPECIAL_CASE_HOSTS = (
    'www.businesslink.gov.uk'                   => 'Businesslink',
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
          $config_rule_type = "Mappings::LocationConfig";
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
sub get_suggested_link {
    my $self   = shift;
    my $lookup = shift;
    my $is_map = shift;

    return unless defined $self->{'suggested'} && length $self->{'suggested'};

    # strip trailing slashes for predictable matching in 410 page code
    $lookup =~ s{/\?$}{};

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

    return "\$query_suggested_link['${lookup}'] = \"${links}\";\n"
        if $is_map;
    return "\$location_suggested_link['${lookup}'] = \"${links}\";\n";
}
sub get_archive_link {
    my $self     = shift;
    my $location = shift;

    return unless defined $self->{'archive_link'} && length $self->{'archive_link'};

    # strip trailing slashes for predictable matching in 410 page code
    $location =~ s{/\?$}{};

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
