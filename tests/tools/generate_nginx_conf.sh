#!/bin/sh

#
#  simplest
#
tools/generate_nginx_conf.sh foo www.foo.com > /tmp/generate.out 2> /tmp/generate.err

diff /tmp/generate.err - <<!
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

diff /tmp/generate.out - <<!
server {
    server_name     www.foo.com
                    aka.foo.com;
    root            /var/apps/redirector/static/foo;
    include         /var/apps/redirector/common_nginx_settings.conf;
    include         /var/apps/redirector/common_status_pages.conf;
    include         /var/apps/redirector/www.foo.com.location.conf;
}
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 3; }

#
#  simple
#
tools/generate_nginx_conf.sh foo www.foo.com www.bar.com bar.foo.com > /tmp/generate.out 2> /tmp/generate.err

diff /tmp/generate.err - <<!
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 2; }

diff /tmp/generate.out - <<!
server {
    server_name     www.foo.com
                    aka.foo.com
                    www.bar.com
                    aka.bar.com
                    bar.foo.com
                    aka-bar.foo.com;
    root            /var/apps/redirector/static/foo;
    include         /var/apps/redirector/common_nginx_settings.conf;
    include         /var/apps/redirector/common_status_pages.conf;
    include         /var/apps/redirector/www.foo.com.location.conf;
}
!

[ $? -ne 0 ] && { echo "$0: FAIL" ; exit 3; }

echo "$0: OK"
