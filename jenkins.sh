#!/bin/sh
set -e
mkdir -p dist

# run migratorator_mappings tests
prove -l tests/migratorator_mappings/*.t

# delete any previous mapping errors files
rm -f dist/*


# DIRECTGOV
curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings/filter/status:closed.csv" > dist/directgov_mappings_source.csv
perl -Ilib create_mappings.pl dist/directgov_mappings_source.csv


# BUSINESSLINK
curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > dist/businesslink_mappings_source.csv
perl -Ilib create_mappings.pl dist/businesslink_mappings_source.csv


# NGINX
cp nginx_configs/*.conf dist
exit
