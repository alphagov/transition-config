#!/bin/sh

set -e

. tools/messages.sh

status "Running unit tests ..."
ruby -I. tests/tools/*.rb
prove -lj4 tests/unit/logic/*.t

status "Copying configuration to dist directory ..."
rm -rf dist
mkdir -p dist
rsync -a redirector/. dist/.

status "Processing data/sites.csv ..."
(
    IFS=,
    read titles
    while read site domain redirection_date tna_timestamp title new_site aliases rest
    do
        mappings=dist/${site}_mappings_source.csv
        sitemap=dist/static/${site}/sitemap.xml
        cp data/mappings/${site}.csv $mappings

        status ":: $site :: $title :: $domain ::"

        status "Testing $site mappings are in a valid format ..."
        prove -l tools/validate_csv.pl :: $mappings

        status "Creating mappings for $site ..."
        perl -Ilib tools/create_mappings.pl $mappings

        status "Creating static assets for $site ... "
	set -x
        tools/generate_static_assets.sh "$site" "$domain" "$redirection_date" "$tna_timestamp" "$title" "$new_site"
	set +x

        status "Creating sitemap for $site ..."
        perl tools/sitemap.pl $mappings $domain > $sitemap

        status "Testing sitemap for $site ..."
        prove tools/test_sitemap.pl :: $sitemap $domain
    done
    report
) < data/sites.csv

# report on success
status=$?
if [ $status -ne 0 ] ; then
	error "Redirector build failed" 
	exit $status
fi
ok "Redirector build succeeded."
