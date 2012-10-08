#!/bin/sh
set -e
mkdir -p dist

# run migratorator_mappings logic tests
prove -l tests/migratorator_mappings/logic/*.t

# delete previous config, error files, etc
rm -rf dist/*

# DIRECTGOV
curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings.csv" > dist/directgov_mappings_source.csv
perl -Ilib create_mappings.pl dist/directgov_mappings_source.csv

# BUSINESSLINK
curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > dist/businesslink_mappings_source.csv
perl -Ilib create_mappings.pl dist/businesslink_mappings_source.csv

# NGINX
rsync -a redirector/. dist/.

# CRAFT 410 PAGES
cat \
    redirector/410_preamble.php \
    dist/www.businesslink.gov.uk.*suggested_links*.conf \
    redirector/410_header.php \
    redirector/static/bl/410.html \
        > dist/static/bl/410.php
cp redirector/410_suggested_links.php dist/static/bl

cat \
    redirector/410_preamble.php \
    dist/www.direct.gov.uk.*suggested_links*.conf \
    redirector/410_header.php \
    redirector/static/dg/410.html \
        > dist/static/dg/410.php
cp redirector/410_suggested_links.php dist/static/dg

exit
