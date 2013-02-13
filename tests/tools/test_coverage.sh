#!/bin/sh

#
#  simplest
#
#  Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options
cat > /tmp/sites-test.csv  <<-!
Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options
site,one.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias1.example.com alias2.example.com,Validate Options
site,two.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias3.example.com,Validate Options
site,three.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias4.example.com,Validate Options
!

tools/test_coverage.sh --sites /tmp/sites-test.csv > /tmp/coverage.out 2> /tmp/coverage.err <<!
Old Url,New Url,Status
http://two.example.com/foo,,410
http://four.example.com/bar,http://example.com/snark,301
http://alias2.example.com/bar,http://example.com/snark,301
http://alias3.example.com/bar,http://alias1.example.com/snark,301
!

diff /tmp/coverage.err - <<!
missing mappings
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

diff /tmp/coverage.out - <<!
alias1.example.com
alias4.example.com
four.example.com
one.example.com
three.example.com
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 3; }

echo "$0: OK"
