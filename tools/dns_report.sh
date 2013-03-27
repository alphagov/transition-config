#!/bin/sh

tmpdir=tmp/dns_report
mkdir -p $tmpdir

tools/site_hosts.sh |
    while read host
    do
        dig +trace $host > $tmpdir/$host.txt
    done

cat $tmpdir/*.txt | tools/dns_report.pl
