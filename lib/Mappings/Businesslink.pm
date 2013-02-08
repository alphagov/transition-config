package Mappings::Businesslink;

use strict;
use warnings;
use base 'Mappings::MapConfig';



sub get_map_key {
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
    elsif ( defined $query_string && $query_string =~ m{page=(\w+)} ) {
        my $page = $1;
        $key = "page=$page";
    }
    
    return $key; 
}

1;
