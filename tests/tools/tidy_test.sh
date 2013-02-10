#!/bin/sh

tools/tidy_mappings.pl > /tmp/tidy.out 2> /tmp/tidy.err <<!
Old Url,New Url,Status,Stuff
http://example.com/5,http://snork.com,301
http://example.com/1,http://foo/1,301
http://example.com/1,http://foo/1,301
http://example.com/2,,410
http://example.com/2,http://foo/2,301
http://example.com/3,http://foo/3,301
http://example.com/3,,410
http://example.com/4,http://snark.com,301
http://example.com/4,http://snork.com,301
!

cmp /tmp/tidy.err - <<!
skipping http://example.com/1 line 4
replacing 410 http://example.com/2 with 301 line 6
skipping 410 http://example.com/3 for duplicate 301 line 8
leaving 301 http://example.com/4 duplicates differ line 10
> http://example.com/4,http://snork.com,301
> http://example.com/4,http://snark.com,301

!

[ $? -ne 0 ] && { cat /tmp/tidy.err ; echo "$0: FAIL" ; exit 1; }

cmp /tmp/tidy.out - <<!
Old Url,New Url,Status,Stuff
http://example.com/1,http://foo/1,301
http://example.com/2,http://foo/2,301
http://example.com/3,http://foo/3,301
http://example.com/4,http://snark.com,301
http://example.com/4,http://snork.com,301
http://example.com/5,http://snork.com,301
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

echo "$0: OK"
