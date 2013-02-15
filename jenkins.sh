#!/bin/sh

set -e

cmd=$(basename $0)
sites="data/sites.csv"
tests="y"
validation="y"

usage() {
    echo "usage: $cmd [opts] [mappings.csv ...]" >&2
    echo "    [-s|--sites $sites] sites file" >&2
    echo "    [-n|--skip-validation]      skip validation" >&2
    echo "    [-t|--skip-tests]           skip tests" >&2
    echo "    [-v|--verbose]              verbose" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -s|--sites) shift; sites="$1" ; shift ; continue ;;
    -v|--verbose) set -x ; shift; continue ;;
    -n|--skip-validation) validation=""; shift; continue ;;
    -t|--skip-tests) tests=""; shift;;
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

. tools/messages.sh

if [ -n "$tests" ] ; then
    status "Testing tools ..."
    for t in tests/tools/*.sh ; do $t ; done

    status "Testing munge ..."
    rake -f munge/Rakefile test

    status "Testing logic ..."
    prove -lj4 tests/unit/logic/*.t
fi

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
        conf=dist/configs/${site}.conf
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

        if [ -n "$validate" ] ; then
            status "Validating mappings file for $site ..."
            prove tools/validate_mappings.pl :: --host $host --whitelist $whitelist $validate_options $mappings
        fi

        if [ ! -f $conf ] ; then
            status "Creating nginx config for $site ... "
            tools/generate_nginx_conf.sh "$site" "$host" "$aliases" > $conf
        fi

        status "Creating mappings for $site ..."
        perl -Ilib tools/generate_mappings.pl $mappings

        status "Creating static assets for $site ... "
        tools/generate_static_assets.sh "$site" "$host" "$redirection_date" "$tna_timestamp" "$title" "$new_site"

        status "Creating sitemap for $site ..."
        tools/generate_sitemap.pl $mappings $host > $sitemap

        if [ -n "$validate" ] ; then
            status "Testing sitemap for $site ..."
            prove tools/test_sitemap.pl :: $sitemap $host
        fi
    done
    report
) < $sites

# report on success
status=$?
if [ $status -ne 0 ] ; then
	error "Redirector build failed" 
	exit $status
fi
ok "Redirector build succeeded."
