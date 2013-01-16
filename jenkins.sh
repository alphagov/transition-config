#!/bin/bash

set -e
mkdir -p dist

echo "Running unit tests..."
prove -lj4 tests/unit/logic/*.t

rm -rf dist/*

while IFS=, read site redirected generate_mappings rest
do 
    #baby steps - these are still in BL data
    [ $site = 'elearning' ] && continue
    [ $site = 'ukwelcomes' ] && continue
    cp data/mappings/${site}.csv dist/${site}_mappings_source.csv
    if [ $redirected == N ]; then
        echo "Testing sources are valid for in progress site $site..."
        prove -l tests/unit/sources/${site}_valid_lines.t
    fi
    if [ $generate_mappings == Y ]; then
        echo "Creating mappings from $site source..."
        perl -Ilib create_mappings.pl dist/${site}_mappings_source.csv
    fi

done < sites.csv

echo "Copying configuration to dist directory..."
rsync -a redirector/. dist/.

echo "Creating 410 pages..."
#directgov - note difference here is archive links
cat \
    redirector/410_preamble.php \
    dist/www.direct.gov.uk.*suggested_links*.conf \
    dist/www.direct.gov.uk.archive_links.conf \
    redirector/410_header.php \
    redirector/static/directgov/410.html \
        > dist/static/directgov/410.php
cp redirector/410_suggested_links.php dist/static/directgov

(
    while IFS=, read site redirected generate_mappings old_homepage rest
    do
        if [ ! -f dist/${old_homepage}.location_suggested_links.conf -a ! -f dist/${old_homepage}.location_suggested_links.conf ]; then
            echo $site
            touch dist/${old_homepage}.no_suggested_links.conf
        fi
    done
) < sites.csv

#businesslink


#ukwelcomes
cat \
    redirector/410_preamble.php \
    dist/www.ukwelcomes.businesslink.gov.uk.suggested_links_map.conf \
    redirector/410_header.php \
    redirector/static/ukwelcomes/410.html \
        > dist/static/ukwelcomes/410.php
cp redirector/410_suggested_links.php dist/static/ukwelcomes

#elearning
cat \
    redirector/410_preamble.php \
    dist/elearning.businesslink.gov.uk.*suggested_links*.conf \
    redirector/410_header.php \
    redirector/static/elearning/410.html \
        > dist/static/elearning/410.php
cp redirector/410_suggested_links.php dist/static/elearning

#improve
cat \
    redirector/410_preamble.php \
    dist/improve.businesslink.gov.uk.*suggested_links*.conf \
    redirector/410_header.php \
    redirector/static/improve/410.html \
        > dist/static/improve/410.php
cp redirector/410_suggested_links.php dist/static/improve



while IFS=, read site rest
do 
    [ $site = 'directgov' ] && continue
    [ $site = 'businesslink' ] && continue
    [ $site = 'businesslink_piplinks' ] && continue
    [ $site = 'elearning' ] && continue
    [ $site = 'ukwelcomes' ] && continue
    domain=`case "$site" in
    mod) echo "www.mod.uk" ;;
    *) echo "www.${site}.gov.uk" ;;
    esac`
    
    touch dist/${domain}.no_archive_links.conf 
    #have the ones that don't have suggested links create them
    #do same with archive links
    
    cat \
        redirector/410_preamble.php \
        dist/${domain}.*suggested_links*.conf \
        dist/${domain}.*archive_links*.conf \
        redirector/410_header.php \
        redirector/static/${site}/410.html \
            > dist/static/${site}/410.php
done < sites.csv

echo "Generating sitemaps..."
perl tools/sitemap.pl dist/directgov_mappings_source.csv 'www.direct.gov.uk' > dist/static/directgov/sitemap.xml
prove bin/test_sitemap.pl :: dist/static/directgov/sitemap.xml www.direct.gov.uk
perl tools/sitemap.pl dist/businesslink_mappings_source.csv 'www.businesslink.gov.uk' 'online.businesslink.gov.uk' > dist/static/businesslink/sitemap.xml
prove bin/test_sitemap.pl :: dist/static/businesslink/sitemap.xml www.businesslink.gov.uk online.businesslink.gov.uk
while IFS=, read site rest
do 
    [ $site = 'directgov' ] && continue
    [ $site = 'businesslink' ] && continue
    [ $site = 'businesslink_piplinks' ] && continue
    [ $site = 'elearning' ] && continue
    [ $site = 'ukwelcomes' ] && continue   
    domain=`case "$site" in
    mod) echo "www.mod.uk" ;;
    *) echo "www.${site}.gov.uk" ;;
    esac`

    perl tools/sitemap.pl dist/${site}_mappings_source.csv $domain > dist/static/${site}/sitemap.xml
    prove bin/test_sitemap.pl :: dist/static/${site}/sitemap.xml $domain
done < sites.csv

echo "Redirector build succeeded."
