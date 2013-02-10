#!/bin/sh

#
#  simple
#
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

#
#  actual
#
tools/tidy_mappings.pl --use-actual > /tmp/tidy-a.out 2> /tmp/tidy-a.err <<!
Old Url,New Url,Status,More,Stuff
http://example.com/1,http://foo/1,301
http://example.com/1,http://foo/1,301
http://example.com/2,,410
http://example.com/2,http://foo/2,301
http://example.com/3,http://foo/3,301
http://example.com/3,,410
http://www.direct.gov.uk,http://example.com,301,snoo,snoo
http://www.direct.gov.uk,https://www.gov.uk,301,foo,bar,baz
http://www.businesslink.gov.uk,https://www.gov.uk,301,junk,wonk
http://www.businesslink.gov.uk,http://example.com,301,wink,wink
!

cmp /tmp/tidy-a.err - <<!
skipping http://example.com/1 line 3
replacing 410 http://example.com/2 with 301 line 5
skipping 410 http://example.com/3 for duplicate 301 line 7
using actual http://www.direct.gov.uk,https://www.gov.uk,301,foo,bar,baz line 9
using actual http://www.businesslink.gov.uk,https://www.gov.uk,301,wink,wink line 11
!

[ $? -ne 0 ] && { cat /tmp/tidy-a.err ; echo "$0: FAIL" ; exit 1; }

cmp /tmp/tidy-a.out - <<!
Old Url,New Url,Status,More,Stuff
http://example.com/1,http://foo/1,301
http://example.com/2,http://foo/2,301
http://example.com/3,http://foo/3,301
http://www.businesslink.gov.uk,https://www.gov.uk,301,wink,wink
http://www.direct.gov.uk,https://www.gov.uk,301,foo,bar,baz
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

echo "$0: OK"
