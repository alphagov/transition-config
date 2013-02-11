#!/bin/sh

set -e

. tools/messages.sh

status "Running unit tests ..."
ruby -I. munge/tests/*.rb
tests/tools/*.sh
prove -lj4 tests/unit/logic/*.t

status "Copying configuration to dist ..."
rm -rf dist
mkdir -p dist
rsync -a redirector/. dist/.

status "Copying whitelist to dist ..."
whitelist=dist/whitelist.txt export whitelist
cp data/whitelist.txt $whitelist

status "Generating lrc_map.conf ..."
tools/generate_lrc.pl data/lrc_transactions_source.csv > dist/lrc_map.conf

status "Generating piplinks_maps.conf ..."
tools/generate_piplinks.pl data/piplinks_url_map_source.csv > dist/piplinks_maps.conf

status "Processing data/sites.csv ..."
(
    IFS=,
    read titles
    while read site host redirection_date tna_timestamp title new_site aliases validate_options rest
    do
        mappings=dist/${site}_mappings_source.csv
        sitemap=dist/static/${site}/sitemap.xml
        cp data/mappings/${site}.csv $mappings

        status
        status ":: site: $site"
        status ":: host: $host"
        status ":: redirection_date: $redirection_date"
        status ":: tna_timestamp: $tna_timestamp"
        status ":: title: $title"
        status ":: new_site: $new_site"
        status ":: aliases: $aliases"
        status ":: mappings: $mappings"
        status

        status "Validating mappings file for $site ..."
        set -x
        prove tools/validate_mappings.pl :: --host $host --whitelist $whitelist $validate_options $mappings
        set +x

        status "Creating mappings for $site ..."
        perl -Ilib tools/generate_mappings.pl $mappings

        status "Creating static assets for $site ... "
        tools/generate_static_assets.sh "$site" "$host" "$redirection_date" "$tna_timestamp" "$title" "$new_site"

        status "Creating sitemap for $site ..."
        tools/generate_sitemap.pl $mappings $host > $sitemap

        status "Testing sitemap for $site ..."
        prove tools/test_sitemap.pl :: $sitemap $host
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
