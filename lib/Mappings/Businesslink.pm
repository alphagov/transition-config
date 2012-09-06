package Mappings::Businesslink;

use strict;
use warnings;
use base 'Mappings::Rules';



sub as_nginx_config {
    my $self = shift;
    
    # we must know what URL we are operating on
    return unless $self->{'old_url'};
    
    my $map_key = $self->get_url_key( $self->{'old_url_parts'}{'path'}, $self->{'old_url_parts'}{'query'} );
    my $type    = 'unresolved';
    my $config  = "$self->{'old_url'}\n";
    
    # assume mappings are closed unless otherwise stated
    my $mapping_status = 'closed';
    if ( defined $self->{'whole_tag'} ) {
        $mapping_status = lc $self->{'whole_tag'};
    }
    
    if ( defined $map_key ) {
        if ( 'closed' eq $mapping_status ) {
            if ( '410' eq $self->{'status'} ) {
                # 410 Gone
                $type   = 'gone_map';
                $config = "~${map_key} 410;\n";
            }
            elsif ( '301' eq $self->{'status'} ) {
                if ( length $self->{'new_url'} ) {
                    # 301 Moved Permanently
                    $type   = 'redirect_map';
                    $config = "~${map_key} $self->{'new_url'};\n";
                }
                else {
                    $type = 'no_destination_error';
                }
            }
        }
        elsif ( 'awaiting-content' eq $mapping_status ) {
            # 418 I'm a Teapot -- used to signify "page will exist soon"
            $type   = 'awaiting_content_map';
            $config = "~${map_key} 418;\n";
        }
    }
    
    return( $self->{'old_url_parts'}{'host'}, $type, $config );
}
sub get_url_key {
    my $self         = shift;
    my $path         = shift;
    my $query_string = shift;
    
    my $key;
    my $topic;
    my $item;
    
    $topic = $1
        if $query_string =~ m{topicId=(\d+)};
    $item = $1
        if $query_string =~ m{itemId=(\d+)};
    
    if ( defined $topic && defined $item ) {
        if ( $path =~ m{^/bdotg/action/layer} ) {
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

1;
