package Mappings::Rules;

use strict;
use warnings;

use Mappings::Businesslink;
use URI::Split  qw( uri_split uri_join );

my %HOSTNAME_MAPPINGS = (
    'www.businesslink.gov.uk' => 'Businesslink',
    
    # ignore these for now
    'www.improve.businesslink.gov.uk' => 'Ignore',
    'online.businesslink.gov.uk'      => 'Ignore',
    'businesslink.gov.uk'             => 'Ignore',
    'tariff.businesslink.gov.uk'      => 'Ignore',
    'tariff.nibusinessingo.co.uk'     => 'Ignore',
    'tariff.business.scotland.gov.uk' => 'Ignore',
    'tariff.business.wales.gov.uk'    => 'Ignore',
);



sub new {
    my $class = shift;
    my $row   = shift;
    
    return unless defined $row;
    
    my( $scheme, $host, $path, $query, $frag ) = uri_split $row->{'Old Url'};
    my $old_url_relative = uri_join undef, undef, $path, $query, $frag;
    
    my $actual_class = defined $HOSTNAME_MAPPINGS{$host}
                           ? "Mappings::$HOSTNAME_MAPPINGS{$host}"
                           : $class;
    
    my $self = {
        old_url          => $row->{'Old Url'},
        old_url_relative => $old_url_relative,
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
    };
    bless $self, $actual_class;
    
    # strip potential trailing whitespace from urls
    $self->{'new_url'} =~ s{\s+$}{};
    $self->{'old_url'} =~ s{\s+$}{};
    $self->{'old_url_relative'} =~ s{\s+$}{};
    
    return $self;
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
    
    # we must know what URL we are operating on
    return unless $self->{'old_url'};
    
    # assume mappings are closed unless otherwise stated
    my $mapping_status = 'closed';
    if ( defined $self->{'whole_tag'} && $self->{'whole_tag'} =~ m{status:(\S+)} ) {
        $mapping_status = $1;
    }
    
    my $type = 'location';
    my $config;
    
    if ( 'closed' eq $mapping_status ) {
        if ( '410' eq $self->{'status'} ) {
            # 410 Gone
            $config = "location = $self->{'old_url_relative'} { return 410; }\n";
        }
        elsif ( '301' eq $self->{'status'} ) {
            # 301 Moved Permanently
            if ( length $self->{'new_url'} ) {
                $config = "location = $self->{'old_url_relative'} { return 301 $self->{'new_url'}; }\n";
            }
            else {
                $type   = 'no_destination_error';
                $config = "$self->{'old_url'}\n";
            }
        }
    }
    elsif ( 'awaiting-content' eq $mapping_status ) {
        # 418 I'm a Teapot -- used to signify "page will exist soon"
        $config = "location = $self->{'old_url_relative'} { return 418; }\n";
    }
    else {
        $type   = 'unresolved';
        $config = "$self->{'old_url'}\n";
    }
    
    return( $self->{'old_url_parts'}{'host'}, $type, $config );
}



1;
