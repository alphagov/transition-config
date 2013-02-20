#!/bin/sh

set -e

sites="data/sites.csv"
whitelist="data/whitelist.txt"
cache="./cache"
document_url='https://whitehall-admin.production.alphagov.co.uk/government/all_document_attachment_and_non_document_mappings.csv'
document_file="tmp/document_mappings.csv"
user="$WHITEHALL_AUTH"
fetch="y"
verbose=""

usage() {
    echo "usage: $cmd [opts] site" >&2
    echo "    [-n|--no-fetch]             don't fetch site mappings" >&2
    echo "    [-s|--sites $sites] sites file" >&2
    echo "    [-u|--user user:password]   basic authentication credentials for curl" >&2
    echo "    [-w,--whitelist filename]   constrain New Urls to those in a whitelist"
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -n|--no-fetch) shift ; fetch="" ; continue;;
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -u|--user) shift; user="$1" ; shift ; continue;;
    -w|--whitelist) shift; whitelist="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

. tools/env

site=$1 ; [ -z "$site" ] && usage
mappings="./data/mappings/${site}.csv"

host=$(awk -F, '$1 == "'$site'" { print $2 }' $sites)
validate_options=$(awk -F, '$1 == "'$site'" { print $8 }' $sites)
fetch_list="data/fetch.csv"
all_file="$cache/$site/_all.csv"

if [ ! -d "$cache" ] ; then
    set -x
    mkdir -p "$cache"
    set +x
fi

if [ ! -s "$document_file" ]; then
    status "Fetching $document_file from production ..."
    set -x
    curl -s -u "$user" "$document_url" > $document_file
    set +x
fi

status "Generating mappings ..."
if [ -n "$fetch" ]; then
    status "Fetching mappings for $site ..."
    set -x
    tools/fetch_mappings.sh --fetch "$fetch_list" --cache-dir "$cache" "$site"
    set +x
fi

status "Concatenating mappings ..."
files=$(awk -F, "\$1 == \"$site\" { print \"$cache/$site/\" \$2 \".csv\" }" $fetch_list)
set -x
cat $files > $all_file
set +x

status "Munging and tidying mappings ..."
set -x
cat $all_file |
    ./munge/munge.rb $document_file |
    ./tools/fold-mappings.rb |
    ./tools/choose-status.rb |
    ./munge/strip-empty-quotes-and-whitespace.rb |
    ./tools/tidy_mappings.pl --trump $validate_options > ${mappings}_tmp

mv ${mappings}_tmp ${mappings}
set +x

status "Validating mappings ..."
set -x
prove tools/validate_mappings.pl :: --host "$host" --whitelist "$whitelist" $validate_options $mappings
set +x

status "Done"
