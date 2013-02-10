#
#  canonicalise a URL
#
sub c14n_url {
    my ($url) = @_;
    $url = lc($url);
    $url =~ s/\?*$//;
    $url =~ s/\/*$//;
    $url =~ s/\#*$//;
    $url =~ s/,/%2C/;
    return $url;
}

1;
