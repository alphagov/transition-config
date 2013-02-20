#!/bin/sh

errors() {
    sed -e '/^# *at tools\/validate_sites.pl/d' -e '/^# *Looks/d' /tmp/validate.err > /tmp/validate.errors
}

#
#  wrong columns
#
cat > /tmp/validate.in <<!
Old Url,Status,New Url,Status,Stuff
!
tools/validate_sites.pl /tmp/validate.in > /tmp/validate.out 2> /tmp/validate.err

errors

diff /tmp/validate.errors - <<!
#   Failed test 'incorrect column names [Old Url,Status,New Url,Status,Stuff]'
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

#
#  simple tests
#
cat > /tmp/validate.in <<!
Site,Host,Redirection Date,TNA Timestamp,Title,FURL,Aliases,Validate Options,New Url,Status
example1,www.example1.gov.uk,13th December 2012,20120816224015,Department One,/example1,,,https://www.gov.uk/government/example1
bad-site-name,www.example2.gov.uk,13th December 2012,20120816224015,Somebody&#39;s Office,/example2,,,https://www.gov.uk/government/example2
example3,www.example3.gov.uk,13th December 2012,20120816224015,Department of Stuff&#44; Stuff &amp; Stuff,,,,https://www.gov.uk/government/example3
example3,www.example3.gov.uk,13th December 2012,20120816224015,Somebody&#39;s Office,/example3,,,https://www.gov.uk/government/example3
example4,www.example4.gov.uk,1st May 2012,20120816224015, Office,/example4,www.example1.gov.uk,,https://www.gov.uk/government/example4
example5,www.example5.gov.uk,13th December 2012,20120816225015,Department of Stuff&#45; Stuff & Bare ampersands,/example5,,,https://www.gov.uk/government/example5
example6,www.example6.gov.uk,13th January 2012,2020866224065,Department One,/example6,,,https://www.gov.uk/government/example6
example6,www.example6.gov.uk,23rd December 2012,20120866294065,Department One,/example6,,,https://www.gov.uk/government/example6
example6,www.example6.gov.uk,13th December 2012,20120866294065,Department One,/example6,,,https://www.gov.uk/government/example6
example7,www.example7.gov.uk,13th July 2015,,Department One,/example6,,,https://www.gov.uk/government/example6
example8,www.example8.gov.uk,13th July 2015,20121017202223,Department One,https://www.gov.uk/example8,,,https://www.gov.uk/government/example8
!
tools/validate_sites.pl /tmp/validate.in > /tmp/validate.out 2> /tmp/validate.err

errors

diff /tmp/validate.errors - <<!
#   Failed test 'invalid site name'
#   Failed test 'duplicate site [example3] [example3] /tmp/validate.in line 5'
#   Failed test 'duplicate host [www.example3.gov.uk] [example3] /tmp/validate.in line 5'
#   Failed test 'duplicate host [www.example1.gov.uk] [example4] /tmp/validate.in line 6'
#   Failed test 'title incorrectly HTML encoded'
#          got: 'Department of Stuff&#45; Stuff & Bare ampersands'
#     expected: 'Department of Stuff- Stuff &amp; Bare ampersands'
#   Failed test 'invalid TNA timestamp format [2020866224065] [example6] /tmp/validate.in line 8'
#   Failed test 'invalid TNA timestamp time [2020866224065] [2020-86-62T24:06:00 UTC] [example6] /tmp/validate.in line 8'
#   Failed test 'duplicate site [example6] [example6] /tmp/validate.in line 9'
#   Failed test 'duplicate host [www.example6.gov.uk] [example6] /tmp/validate.in line 9'
#   Failed test 'invalid TNA timestamp time [20120866294065] [2012-08-66T29:40:65 UTC] [example6] /tmp/validate.in line 9'
#   Failed test 'duplicate site [example6] [example6] /tmp/validate.in line 10'
#   Failed test 'duplicate host [www.example6.gov.uk] [example6] /tmp/validate.in line 10'
#   Failed test 'invalid TNA timestamp time [20120866294065] [2012-08-66T29:40:65 UTC] [example6] /tmp/validate.in line 10'
#   Failed test 'invalid TNA timestamp format [] [example7] /tmp/validate.in line 11'
#   Failed test 'invalid TNA timestamp time [] [0000-00-00T00:00:00 UTC] [example7] /tmp/validate.in line 11'
#   Failed test 'invalid furl [https://www.gov.uk/example8] [example8] /tmp/validate.in line 12'
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

echo "$0: OK"
