#!/bin/bash

#
#  test static assets served for each host mentioned in sites
#
cmd=$(basename $0)
sites="data/sites"
tmpfile="tmp/static_assets.csv"
tmpout="tmp/static_assets.txt"
export DEPLOY_TO=${DEPLOY_TO:=dev}
export REDIRECTOR=${REDIRECTOR:=redirector.$DEPLOY_TO.alphagov.co.uk}
echo REDIRECTOR=$REDIRECTOR

usage() {
    echo "usage: $cmd) [opts] [-- test_mappings opts]" >&2
    echo "    [-s|--sites sites]  sites dir" >&2
    echo "    [-?|--help]         print usage" >&2
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
(
echo "Old Url,New Url,Status"

ls -1 $sites/*.yml |
    while read file
    do
        site=$(basename $file .yml)
        host=$(grep "^host:" $file | sed 's/^.*: //')
        homepage=$(grep "^homepage:" $file | sed 's/^.*: //')
        [ -z "$host" ] && continue

        # homepage redirect
        echo "http://$host,$homepage,301"
        echo "http://$host/,$homepage,301"

        # static assets
        echo "http://$host/robots.txt,,200"
        echo "http://$host/sitemap.xml,,200"
        echo "http://$host/favicon.ico,,200"

        echo "http://$host/404,,404"
        echo "http://$host/410,,410"
    done
) > $tmpfile

tools/test_mappings.pl "$@" $tmpfile

#
#  content checks
#
(
ls -1 $sites/*.yml |
    while read file
    do
        site=$(basename $file .yml)

        case "$site" in
        businesslink_lrc) continue;;
        esac

        host=$(grep "^host:" $file | sed 's/^.*: //')
        [ -z "$host" ] && continue

        tna_timestamp=$(grep "^tna_timestamp:" $file | sed 's/^.*: //')

        expected="http://webarchive.nationalarchives.gov.uk/$tna_timestamp/http://$host/410"
        curl -s -H "host: $host" "http://$REDIRECTOR/410" > $tmpout
        grep -q "$expected" $tmpout || {
            echo "incorrect or missing archive link: $host/410" >&2
            echo "expected: [$expected]"
            grep "webarchive" $tmpout
            exit 1
        }
    done
)

#
#  suggested link checks
#
while read host path expected
do
    curl -s -H "host: $host" "http://$REDIRECTOR$path" > $tmpout
    grep -q "$expected" $tmpout || {
        echo "incorrect or missing suggested link: http://$host$path" >&2
        echo "expected: [$expected]"
        grep "more information" $tmpout
        exit 1
    }
done <<-!
www.direct.gov.uk /en/employment/jobseekers/helpapplyingforajob/dg_173685 https://nationalcareersservice.direct.gov.uk
www.direct.gov.uk /barrierbusting http://barrierbusting.communities.gov.uk/
www.businesslink.gov.uk /bdotg/action/detail?itemid=1073792781 http://www.cips.org/en-GB/
!

exit 0
