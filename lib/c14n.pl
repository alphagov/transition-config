#
#  canonicalise (normalize) a URL
#  http://tools.ietf.org/html/rfc3986#section-6.2
#
use URI;

sub c14n_url {
    my ($url, $query_values) = @_;

    my $uri = URI->new($url);
    $url = URI->new($url)->canonical;

    # all our nginx location and map matches are case-insensitive
    # ordinarily a bad idea for resources, this removes a lot of duplicate mappings
    $url = lc($url);

    # protocol should be http
    $url =~ s/^https/http/;

    # remove query_string
    unless ($allow_query_string) {
        $url =~ s/\?.*$//;
    }

    # remove fragment identifier
    $url =~ s/\#.*$//;

    # remove trailing insignificant characters
    $url =~ s/\/*$//;

    # escape characters problematic in CSV
    $url =~ s/"/%22/g;
    $url =~ s/'/%27/g;
    $url =~ s/,/%2c/g;

    # escape some characters problematic in an nginx regex
    $url =~ s/\|/%7c/g;
    $url =~ s/\[/%5b/g;
    $url =~ s/\]/%5d/g;

    # add canonicalised query string
    if ($query_values) {
        my $query = c14n_query_string($uri->query, $query_values);
        $url = "$url?$query" if ($query);
    }

    return $url;
}

sub c14n_query_string {
    my ($query, $query_values) = @_;

    my $wildcard = $query_values eq '*';

    # significant query values
    my %significant = map { $_ => 1 } split(/[:,\s]+/, $query_values);

    my @param; 

    foreach my $pair (split(/[&;]/, $query)) {
        # only keep significant query_string values
        my $value = $pair;
        $value =~ s/=.*$//;
        push(@param, $pair) if ($significant{$value} || $wildcard);
    }

    return join('&', sort(@param));
}

1;
