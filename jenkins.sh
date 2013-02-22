#!/bin/sh

set -e

cmd=$(basename $0)
sites="data/sites.csv"
whitelist="data/whitelist.txt"
blacklist="data/blacklist.txt"
tests="y"
validate="y"
IFS=,

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
    -n|--skip-validation) validate=""; shift; continue ;;
    -t|--skip-tests) tests=""; shift; continue ;;
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

. tools/env

if [ -n "$tests" ] ; then
    status "Testing tools ..."
    for t in tests/tools/*.sh ; do set -x ; $t ; set +x ; done

    status "Testing munge ..."
    rake -f munge/Rakefile test

    status "Testing logic ..."
    prove -lj4 tests/unit/logic/*.t
fi

status "Creating dist directory ..."
rm -rf dist

status "Copying configuration to dist ..."
mkdir -p dist/configs
cp configs/* dist/configs

status "Copying common nginx confing to dist ..."
mkdir -p dist/common
cp common/* dist/common

if [ -n "$validate" ] ; then
    prove tools/validate_sites.pl :: $sites
fi

status "Generating tests for Smokey"
tools/generate_smokey_tests.sh --sites $sites > dist/redirector.feature

status "Generating bespoke maps .."
while read site map
do
    status "Generating $site map ..."
    mkdir -p dist/maps/$site
    tools/generate_$map.pl data/$map.csv > dist/maps/$site/$map.conf
done <<!
lrc,lrc
businesslink,piplinks
!

status "Processing data/sites.csv ..."
tail -n +2 $sites |
    while read site host redirection_date tna_timestamp title furl aliases validate_options homepage rest
    do
        mappings=data/mappings/${site}.csv
        sitemap=dist/static/${site}/sitemap.xml
        conf=dist/configs/${site}.conf
        locations=dist/${host}.location.conf

        status
        status ":: site: $site"
        status ":: host: $host"
        status ":: redirection_date: $redirection_date"
        status ":: tna_timestamp: $tna_timestamp"
        status ":: title: $title"
        status ":: furl: $furl"
        status ":: aliases: $aliases"
        status ":: validate_options: $validate_options"
        status ":: homepage: $homepage"
        status ":: mappings: $mappings"
        status

        if [ -n "$validate" ] ; then
            status "Validating mappings file for $site ..."
            prove tools/validate_mappings.pl :: --host $host --whitelist $whitelist --blacklist $blacklist $validate_options $mappings
        fi

        if [ ! -f $conf ] ; then
            status "Creating nginx config for $site ... "
            tools/generate_nginx_conf.sh --site "$site" --homepage "$homepage" "$host" $aliases > $conf
        fi

        status "Creating nginx maps for $site ..."
        tools/generate_maps.pl $site $mappings

        status "Creating static assets for $site ... "
        tools/generate_static_assets.sh "$site" "$host" "$redirection_date" "$tna_timestamp" "$title" "$furl" "$homepage"

        status "Creating sitemap for $site ..."
        tools/generate_sitemap.pl $mappings $host > $sitemap

        if [ -n "$validate" ] ; then
            status "Testing sitemap for $site ..."
            prove tools/test_sitemap.pl :: $sitemap $host
        fi
    done

exit $?
