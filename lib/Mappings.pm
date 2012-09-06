package Mappings;

use strict;
use warnings;

use Text::CSV;
use URI::Split  qw( uri_split uri_join );



sub new {
    my $class    = shift;
    my $csv_file = shift;
    
    my $self = {};
    bless $self, $class;
    
    $self->{'csv'} = Text::CSV->new({ binary => 1 });
    open $self->{'csv_handle'}, '<:encoding(utf8)', $csv_file
        or return undef;
    
    $self->{'column_names'} = $self->read_column_names();
    return unless scalar @{$self->{'column_names'}};
    return unless $self->has_mandatory_columns();
    
    return $self;
}

sub entire_csv_as_nginx_config {
    my $self = shift;
    
    my %configs;
    while ( my( $host, $map, $line ) = $self->row_as_nginx_config($self->get_row) ) {
        if ( defined $host && defined $map && defined $line ) {
            $configs{$host}{$map} = []
                unless defined $configs{$host};
            push @{ $configs{$host}{$map} }, $line;
        }
    }
    
    foreach my $host ( keys %configs ) {
        foreach my $map ( keys %{ $configs{$host} } ) {
            if ( 'location' eq $map ) {
                # locations need to be sorted for b-tree insert efficiency
                $configs{$host}{$map} = join '', sort @{ $configs{$host}{$map} };
            }
            else {
                $configs{$host}{$map} = join '', @{ $configs{$host}{$map} };
            }
        }
    }
    
    return \%configs;
}
sub row_as_nginx_config {
    my $self = shift;
    my $row  = shift; 

    return unless defined $row;
    
    my $status  = $row->{'Status'};
    my $new_url = $row->{'New Url'};
    
    my( $scheme, $host, $path, $query, $frag ) = uri_split $row->{'Old Url'};

    my $old_url = uri_join undef, undef, $path, $query, $frag;
        
        # strip potential trailing whitespace
        $new_url =~ s{\s+$}{};
        $old_url =~ s{\s+$}{};
    
    if ( 'www.direct.gov.uk' eq $host ) {
        return( $host, 'location', "location = $old_url { return 410; }\n" )
            if '410' eq $status && length $old_url;
        return( $host, 'location', "location = $old_url { return 301 $new_url; }\n" )
            if '301' eq $status && length $old_url && length $new_url;
        
        my $whole_tag = $row->{'Whole Tag'};

        if ( defined $whole_tag && $whole_tag =~ m{status:(\S+)}) {
            my $mapping_status = $1;

            if ( 'awaiting-content' eq $mapping_status ) {
                return( $host, 'location', "location = $old_url { return 418; }\n" );
            }
            elsif ( 'closed' eq $mapping_status ) {

            } 
            elsif ( 'open' eq $mapping_status ) {

            }
            else {
                die "Whole Tag column contains unexpected status";
            }
        }

        return(
            $host,
            'location',
            "# invalid entry: status='$status' old='$row->{'Old Url'}' new='$new_url'\n"
        );
    } 

    if ( 'www.businesslink.gov.uk' eq $host ) {
        my $key = $self->get_url_key($old_url);
        if ( defined $key ) {
            my $config_line;

            if ( '301' eq $status && length $old_url ) {
                $config_line = "~${key} ${new_url};\n";
                return( $host, "redirect_map", $config_line )
            }

            if ( '410' eq $status && length $old_url )  {
                $config_line = "~${key} 410;\n";
                return( $host, "gone_map", $config_line )
            }

        #something like     my $new_url = $row->{'New Url'};
        #if undef or not awaiting ciontat
        #error ?

        #otherwise we need an awating content map for BL and a location for DG

        }
        else {
            print STDERR "no key for $old_url";
        }     
    } 
    elsif ( 'www.improve.businesslink.gov.uk' eq $host || 'online.businesslink.gov.uk' eq $host 
        || 'businesslink.gov.uk' eq $host || 'tariff.businesslink.gov.uk' eq $host 
        || 'tariff.nibusinessingo.co.uk' eq $host || 'tariff.business.scotland.gov.uk' eq $host 
        || 'tariff.business.wales.gov.uk' eq $host ) {
            # do nothing... for now.
    }

    else {
        print STDERR "problem with $row->{'Old Url'}\n";
    }
}

sub get_url_key {
    my $self = shift;
    my $url  = shift;
    
    my $key;
    my $topic;
    my $item;
    
    $topic = $1
        if $url =~ m{topicId=(\d+)};
    $item = $1
        if $url =~ m{itemId=(\d+)};
    
    if ( defined $topic && defined $item ) {
        if ( $url =~ m{^/bdotg/action/layer} ) {
            $key = "topicId=$topic";
        }
        else {
           $key = "itemId=$item";
        }
    }
    elsif ( defined $topic ) {
        $key = "topicId=$topic";
    }
    elsif ( defined $item ) {
        $key = "itemId=$item";
    }

    return $key; 
}


sub get_row {
    my $self = shift;
    return $self->{'csv'}->getline_hr( $self->{'csv_handle'} );
}

sub read_column_names {
    my $self = shift;
    
    my $names = $self->{'csv'}->getline( $self->{'csv_handle'} );
    return unless scalar @$names;
    
    $self->{'csv'}->column_names( @$names );
    return $names;
}
sub has_mandatory_columns {
    my $self = shift;
    
    my $has_status  = 0;
    my $has_old_url = 0;
    my $has_new_url = 0;
    foreach my $col ( @{$self->{'column_names'}} ) {
        $has_status  = 1 if 'Status'  eq $col;
        $has_old_url = 1 if 'Old Url' eq $col;
        $has_new_url = 1 if 'New Url' eq $col;
    }
    
    return 1 if $has_status && $has_old_url && $has_new_url;
    return 0;
}

1;
