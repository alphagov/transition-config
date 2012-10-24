#!/bin/sh
set -e
mkdir -p dist

# run unit logic tests
prove -l tests/unit/logic/*.t

# delete previous config, error files, etc
rm -rf dist/*

# DIRECTGOV
curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings.csv" > dist/directgov_mappings_source.csv
perl -Ilib create_mappings.pl dist/directgov_mappings_source.csv

# BUSINESSLINK
curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > dist/businesslink_mappings_source.csv
perl -Ilib create_mappings.pl dist/businesslink_mappings_source.csv

# OTHER TEST DATA
cp data/businesslink_piplink_redirects_source.csv dist

# BUSINESSLINK LRC
# creates redirector/lrc_map.conf
# perl tools/lrc_map_maker.pl data/lrc_transactions_source.csv
touch redirector/lrc_map.conf

# log testdata for reference
# tools/lrc.sh > dist/lrc.csv
# prove tools/test-log.pl  < dist/lrc.csv 2> dist/lrc.errors

# NGINX
rsync -a redirector/. dist/.

# CRAFT 410 PAGES
cat \
    redirector/410_preamble.php \
    dist/www.businesslink.gov.uk.*suggested_links*.conf \
    dist/www.ukwelcomes.businesslink.gov.uk.suggested_links_map.conf \
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

prove -l tests/unit/sources/valid_lines.t

# generate sitemaps
perl tools/sitemap.pl dist/directgov_mappings_source.csv 'www.direct.gov.uk' > dist/static/dg/sitemap.xml
perl tools/sitemap.pl dist/businesslink_mappings_source.csv 'www.businesslink.gov.uk' 'online.businesslink.gov.uk' > dist/static/bl/sitemap.xml
prove -l tests/unit/sources/valid_sitemaps.t

exit
