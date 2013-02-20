#!/bin/sh

set -e

sites="data/sites.csv"
whitelist="data/whitelist.txt"
tmpdir="tmp"
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

. tools/messages.sh

site=$1 ; [ -z "$site" ] && usage
mappings="./data/mappings/${site}.csv"

host=$(awk -F, '$1 == "'$site'" { print $2 }' $sites)
validate_options=$(awk -F, '$1 == "'$site'" { print $8 }' $sites)
fetch_cmd="./munge/fetch_${site}_mappings.rb"
fetch_file="$tmpdir/fetch.$site.csv"

if [ ! -d "$tmpdir" ] ; then
    set -x
    mkdir -p "$tmpdir"
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
    status "Fetching mappings for $host ..."
    set -x
    ./munge/extract-mappings.rb $host < "$document_file" | "$fetch_cmd" > "$fetch_file"
    set +x
fi

status "Munging and tidying mappings ..."
set -x
cat $fetch_file |
    ./munge/munge.rb $document_file |
    ./tools/fold-mappings.rb |
    ./tools/choose-status.rb |
    ./munge/strip-empty-quotes-and-whitespace.rb |
    ./munge/reverse-csv.rb |
    ./tools/tidy_mappings.pl --trump $validate_options > ${mappings}_tmp

mv ${mappings}_tmp ${mappings}
set +x

status "Validating mappings ..."
set -x
prove tools/validate_mappings.pl :: --host "$host" --whitelist "$whitelist" $validate_options $mappings
set +x

status "Done"
