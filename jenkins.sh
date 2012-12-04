#!/bin/bash

set -e
mkdir -p dist

source sites.sh

function error_exit() {
    echo "$@" 1>&2
    exit 1
}

# run unit logic tests
prove -lj4 tests/unit/logic/*.t

# delete previous config, error files, etc
rm -rf dist/*

# copy the mappings source files to dist
TEST_FILES=''
for site in ${REDIRECTOR_SITES[@]}; do
    # no mapping source for directgov as yet
    [ $site = 'directgov' ] && continue
    
    cp data/mappings/${site}.csv dist/${site}_mappings_source.csv
    
    test_file="tests/unit/sources/${site}_valid_lines.t"
    [ -f $test_file ] || error_exit "No test '${test_file}'"
    TEST_FILES="${TEST_FILES} ${test_file}"
done

# fetch directgov
echo 'Fetching directgov from the migratorator'
curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings.csv" > dist/directgov_mappings_source.csv

# copy extra businesslink piplinks
cp data/businesslink_piplink_redirects_source.csv dist

# check the data sources for problems
prove -lj4 $TEST_FILES tests/unit/sources/directgov_valid_lines.t

# create the mappings from the source CSV files
for site in ${REDIRECTOR_SITES[@]}; do
    perl -Ilib create_mappings.pl dist/${site}_mappings_source.csv
done

# copy configuration to dist for archiving
rsync -a redirector/. dist/.

# create the 410 pages
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
    dist/www.improve.businesslink.gov.uk.*suggested_links*.conf \
    redirector/410_header.php \
    redirector/static/improve/410.html \
        > dist/static/improve/410.php
cp redirector/410_suggested_links.php dist/static/improve

cat \
    redirector/410_preamble.php \
    dist/www.direct.gov.uk.*suggested_links*.conf \
    dist/www.direct.gov.uk.archive_links.conf \
    redirector/410_header.php \
    redirector/static/dg/410.html \
        > dist/static/dg/410.php
cp redirector/410_suggested_links.php dist/static/dg

for site in ${REDIRECTOR_SITES[@]}; do
    [ $site = 'directgov' ] && continue
    [ $site = 'businesslink' ] && continue
    
    touch dist/www.${site}.gov.uk.no_suggested_links.conf
    
    cat \
        redirector/410_preamble.php \
        dist/www.${site}.gov.uk.*suggested_links*.conf \
        redirector/410_header.php \
        redirector/static/${site}/410.html \
            > dist/static/${site}/410.php
done

# generate sitemaps
perl tools/sitemap.pl dist/directgov_mappings_source.csv 'www.direct.gov.uk' > dist/static/dg/sitemap.xml
perl tools/sitemap.pl dist/businesslink_mappings_source.csv 'www.businesslink.gov.uk' 'online.businesslink.gov.uk' > dist/static/bl/sitemap.xml
for site in ${REDIRECTOR_SITES[@]}; do
    [ $site = 'directgov' ] && continue
    [ $site = 'businesslink' ] && continue
    
    perl \
        tools/sitemap.pl \
        dist/${site}_mappings_source.csv \
        www.${site}.gov.uk > dist/static/${site}/sitemap.xml
done

echo "Redirector build succeeded."
