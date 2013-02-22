#!/bin/sh

set -e

sites="data/sites.csv"
whitelist="data/whitelist.txt"
cache="./cache"
whitehall_url='https://whitehall-admin.production.alphagov.co.uk/government/all_document_attachment_and_non_document_mappings.csv'
whitehall="cache/whitehall.csv"
fetch_list="data/fetch.csv"
user="$WHITEHALL_AUTH"
fetch="y"
verbose=""
mappings_dir='./data/mappings'

usage() {
    echo "usage: $cmd [opts] site" >&2
    echo "    [-n|--no-fetch]             don't fetch site mappings" >&2
    echo "    [-s|--sites filename] sites file (default: $sites)" >&2
    echo "    [-u|--user user:password]   basic authentication credentials for curl" >&2
    echo "    [-w,--whitelist filename]   constrain New Urls to those in a whitelist (default: $whitelist)" >&2
    echo "    [-W,--whitehall filename]   use this file as the whitehall input file (default: $whitehall)" >&2
    echo "    [-C,--cache directory]      use this directory for caching (default: $cache)" >&2
    echo "    [-F,--fetch-list filename]  use this file as the fetch list (default: $fetch_list)"
    echo "    [-o,--output directory]     write mappings output file to this directory (default: $mappings_dir)"
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -n|--no-fetch) shift ; fetch="" ; continue;;
    -s|--sites) shift; sites="$1" ; shift ; continue;;
    -u|--user) shift; user="$1" ; shift ; continue;;
    -w|--whitelist) shift; whitelist="$1" ; shift ; continue;;
    -W|--whitehall) shift; whitehall="$1" ; shift ; continue;;
    -C|--cache) shift; cache="$1" ; shift ; continue;;
    -F|--fetch-list) shift; fetch_list="$1" ; shift ; continue;;
    -o|--output) shift; mappings_dir="$1" ; shift ; continue;;
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

. tools/env

site=$1 ; [ -z "$site" ] && usage

mappings="${mappings_dir}/${site}.csv"
host=$(awk -F, '$1 == "'$site'" { print $2 }' $sites)
validate_options=$(awk -F, '$1 == "'$site'" { print $8 }' $sites)
all_file="$cache/$site/_all.csv"
site_whitehall="$cache/$site/_whitehall.csv"

if [ ! -d "$cache" ] ; then
    set -x
    mkdir -p "$cache"
    set +x
fi


if [ ! -s "$whitehall" ]; then
    # TBD: - use wget --timestamping for caching this
    status "Fetching $whitehall from production ..."
    set -x
    curl -s -u "$user" "$whitehall_url" > $whitehall
    set +x
fi


if [ -n "$fetch" ]; then
    status "Fetching mappings for $site ..."
    set -x
    tools/fetch_mappings.sh --fetch "$fetch_list" --cache-dir "$cache" "$site"
    set +x
fi


status "Extracting mappings from Whitehall ..."
# 1       2       3      4         5    6         7
# Old Url,New Url,Status,Whole Tag,Slug,Admin Url,State
{
    echo "old url,new url,status,source,row_number"
    grep -E "^\"*https*://$host[/,]" $whitehall |
        sed 's/""//g' |
        cut -d , -f 1,2,3
} > $site_whitehall


status "Concatenating mappings ..."
(
    set -x
    all_files=$(perl -e 'print reverse <>' $fetch_list | awk -F, "\$1 == \"$site\" { print \"$cache/$site/\" \$2 \".csv\" }")
    set +x

    echo "old url,new url,status,source,row_number"
    #for file in $all_files $site_whitehall
    for file in $site_whitehall $all_files
    do
        set -x
        tail -n +2 "$file"
        set +x
        echo
    done
) | sed -e '/^$/d' > $all_file


status "Munging and tidying mappings ..."
set -x
cat $all_file |
    ./munge/munge.rb $whitehall |
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
