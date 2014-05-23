# usage sh tools/new_tld_rewrite.sh rootdomain.gov.uk

rootdomain=$1

touch tld/$rootdomain
echo 'server {' >> tld/$rootdomain
echo '  server_name '$rootdomain';' >> tld/$rootdomain
echo '  rewrite ^/(.*) http://www.'$rootdomain'/$1 permanent;' >> tld/$rootdomain
echo '}' >> tld/$rootdomain
