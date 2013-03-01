#!/bin/sh

tmpdir=tmp/dig
mkdir -p $tmpdir

touch=tmp/touch
touch $touch
touch -A -001000 $touch

tools/site_hosts.sh |
    while read host
    do
        digout=$tmpdir/$host.txt
        if [ $touch -nt $digout ] ; then
            set -x
            dig +trace $host > $digout
            set +x
        fi
    done

cat $tmpdir/*.txt | tools/dns_report.pl
