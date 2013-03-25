#!/bin/sh

tmpdir=tmp/dns_report
mkdir -p $tmpdir

tools/site_hosts.sh |
    while read host
    do
        set -x
        dig +trace $host > $tmpdir/$host.txt
        set +x
    done

cat $tmpdir/*.txt | tools/dns_report.pl
