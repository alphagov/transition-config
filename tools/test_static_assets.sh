#!/bin/sh

#
#  test static assets served for each host mentioned in sites.csv
#
cmd=$(basename $0)
sites="data/sites.csv"
tmpfile="tmp/static_assets.csv"
tmpout="tmp/static_assets.txt"
redirector="redirector.${DEPLOY_TO:=dev}.alphagov.co.uk"

set -e
usage() {
    echo "usage: $cmd) [opts] [-- test_mappings opts]" >&2
    echo "    [-s|--sites sites.csv]      sites file" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) shift ; break ;;
    -*) usage ;;
    esac
    break
done

mkdir -p $(dirname $tmpfile)

#
#  create mappings for static assets
#
# Site,Host,Redirection Date,TNA Timestamp,Title,FURL,Aliases,Validate Options,New Url
(
echo "Old Url,New Url,Status"
IFS=,
cut -d, -f 2,6,9 "$sites" |
    tail -n +2 |
    while read host furl new_url tna_timestamp
    do
        # home page redirect
        echo "http://$host,$new_url,301"
        echo "http://$host/,$new_url,301"

        # not yet deployed
        # echo "https://www.gov.uk$furl,$new_url,301"

        # static assets
        echo "http://$host/robots.txt,,200"
        echo "http://$host/sitemap.xml,,200"
        echo "http://$host/favicon.ico,,200"
        echo "http://$host/gone.css,,200"

        echo "http://$host/404,,404"
        echo "http://$host/410,,410"
    done
) > $tmpfile

prove tools/test_mappings.pl :: "$@" $tmpfile

#
#  simple content checks
#
(
IFS=,
cut -d, -f 1,2,4 "$sites" |
    tail -n +2 |
    while read site host tna_timestamp
    do
        case "$site" in
        lrc) continue;;
        esac

        expected="http://webarchive.nationalarchives.gov.uk/$tna_timestamp/http://$host/410"
        curl -s -H "host: $host" "http://$redirector/410" > $tmpout
        grep -q "$expected" $tmpout || {
            echo "incorrect or missing archive link: $host/410" >&2
            echo "expected: [$expected]"
            grep "webarchive" $tmpout
            exit 1
        }
    done
)

exit 0
