#
#  canonicalise a URL
#
sub c14n_url {
    my ($url, $allow_query_string) = @_;

    # all our nginx location and map matches are case-insensitive
    # ordinarily a bad idea for resources, this and removes a lot of duplicate mappings
    $url = lc($url);

    # remove query_string
    unless ($allow_query_string) {
        $url =~ s/\?.*$//;
    }

    # remove fragment identifier
    $url =~ s/\#.*$//;

    # remove trailing insignificant characters
    $url =~ s/[\?\/\#]*$//;

    # escape problematic characters
    $url =~ s/"/%22/;
    $url =~ s/'/%27/;
    $url =~ s/,/%2C/;

    return $url;
}

1;
