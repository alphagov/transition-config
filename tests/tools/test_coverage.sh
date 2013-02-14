#!/bin/sh

#
#  simplest
#
#  Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options
cat > /tmp/sites-test.csv  <<-!
Site,Host,Redirection Date,TNA Timestamp,Title,New Site,Aliases,Validate Options
site,host1.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias1.example.com alias2.example.com,Validate Options
site,host2.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias3.example.com,Validate Options
site,host3.example.com,Redirection Date,TNA Timestamp,Title,New Site,alias4.example.com,Validate Options
!

tools/test_coverage.sh --sites /tmp/sites-test.csv > /tmp/coverage.out 2> /tmp/coverage.err <<!
Old Url,New Url,Status
http://host1.example.com/foo,,410
http://host99.example.com/bar,http://example.com/snark,301
http://alias2.example.com/bar,http://example.com/snark,301
http://alias3.example.com/bar,http://alias1.example.com/snark,301
!

diff /tmp/coverage.err - <<!
test_coverage.sh: missing mappings
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

diff /tmp/coverage.out - <<!
> alias1.example.com
> alias4.example.com
> host2.example.com
> host3.example.com
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 3; }

echo "$0: OK"
