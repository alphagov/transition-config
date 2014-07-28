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
            if $query_string =~ m{topicid=(\d+)};
        $item = $1
            if $query_string =~ m{itemid=(\d+)};
    }

    if ( defined $topic && defined $item ) {
        if ( $path =~ m{^/bdotg/action/layer} ) {
            $key = "topicid=$topic";
        }
        else {
           $key = "itemid=$item";
        }
    }
    elsif ( defined $topic ) {
        $key = "topicid=$topic";
    }
    elsif ( defined $item ) {
        $key = "itemid=$item";
    }
    elsif ( defined $query_string && $query_string =~ m{page=(\w+)} ) {
        my $page = $1;
        $key = "page=$page";
    }
    else {
        $key = $query_string;
    }

    return $key;
}

1;
