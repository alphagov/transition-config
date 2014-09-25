# Usage tools/new_tld_rewrite.sh rootdomain.gov.uk
#
# Generate an nginx config file to redirect from the root domain
# (eg bis.gov.uk) to the www. version. We often need to do this for root
# domains.

rootdomain=$1

touch tld/$rootdomain
echo 'server {' >> tld/$rootdomain
echo '  server_name '$rootdomain';' >> tld/$rootdomain
echo '  rewrite ^/(.*) http://www.'$rootdomain'/$1 permanent;' >> tld/$rootdomain
echo '}' >> tld/$rootdomain
