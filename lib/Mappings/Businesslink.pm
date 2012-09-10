package Mappings::Businesslink;

use strict;
use warnings;
use base 'Mappings::Rules';



sub actual_nginx_config {
    my $self = shift;
    
    my $map_key = $self->get_url_key( $self->{'old_url_parts'} );
     
    my $map_or_error_type;
    my $config_line;

    if ( defined $map_key ) {
        if ( '410' eq $self->{'status'} ) {
            # 410 Gone
            $map_or_error_type   = 'gone_map';
            $config_line = "~${map_key} 410;\n";
        }
        elsif ( '301' eq $self->{'status'} ) {
            if ( length $self->{'new_url'} ) {
                # 301 Moved Permanently
                $map_or_error_type   = 'redirect_map';
                $config_line = "~${map_key} $self->{'new_url'};\n";
            } 
            elsif ( defined $self->{'whole_tag'} && lc $self->{'whole_tag'} eq 'awaiting-content' ) {
                # 418 I'm a Teapot -- used to signify "page will exist soon"
                $map_or_error_type   = 'awaiting_content_map';
                $config_line = "~${map_key} 418;\n";
            }
            else {
                $map_or_error_type = 'no_destination_error';
                $config_line = "$self->{'old_url'}\n";
            }
        }
    }
    else {
        $map_or_error_type = 'no_map_key_error'; 
        $config_line = "$self->{'old_url'}\n"; 
    }
    
    return( $self->{'old_url_parts'}{'host'}, $map_or_error_type, $config_line );
}
sub get_url_key {
    my $self         = shift;
    my $parts        = shift;
    
    my $path         = $parts->{'path'};
    my $query_string = $parts->{'query'};
    
    my $key;
    my $topic;
    my $item;
    
    if ( defined $query_string ) {
        $topic = $1
            if $query_string =~ m{topicId=(\d+)};
        $item = $1
            if $query_string =~ m{itemId=(\d+)};
    }
    
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
