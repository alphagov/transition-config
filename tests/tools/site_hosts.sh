#!/bin/sh

#
#  simplest
#
#  Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options
test=/tmp/sites-hosts-test.csv
cat > $test <<-!
Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options
site,one.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias1.example.com alias2.example.com,Validate Options
site,two.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias3.example.com,Validate Options
site,three.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias4.example.com,Validate Options
!

tools/site_hosts.sh --sites $test > /tmp/site-hosts.out 2> /tmp/site-hosts.err <<!

diff /tmp/site-hosts.err - <<!
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

diff /tmp/site-hosts.out - <<!
alias1.example.com
alias2.example.com
alias3.example.com
alias4.example.com
one.example.com
three.example.com
two.example.com
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 3; }

echo "$0: OK"
