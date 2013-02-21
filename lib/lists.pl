#
#  load lists
#
sub load_blacklist {
    my %paths = load_list(@_);
    $paths{''} = 1 if $paths{'/'};
    return %paths;
}

sub load_whitelist {
    return load_list(@_);
}

sub load_list {
    my $filename = shift;
    my %list = ();
    local *FILE;
    open(FILE, "< $filename") or die "unable to open whitelist $filename";
    while (<FILE>) {
        chomp;
        $_ =~ s/\s*\#.*$//;
        $list{$_} = 1 if ($_);
    }
    return %list;
}

1;
