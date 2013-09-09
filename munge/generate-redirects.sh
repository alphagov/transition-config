#!/bin/sh

set -e

sites_directory="data/sites"
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
    echo "    [-s|--sites filename] sites file (default: $sites_directory)" >&2
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
    -s|--sites) shift; sites_directory="$1" ; shift ; continue;;
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

site=$1 ; [ -z "$site" ] && usage

mappings="${mappings_dir}/${site}.csv"
host=`ruby -ryaml -e'puts YAML.load_file("'$sites_directory'/'$site.yml'")["host"]'`
options=`ruby -ryaml -e'puts YAML.load_file("'$sites_directory'/'$site.yml'")["options"]'`
all_file="$cache/$site/_all.csv"
site_whitehall="$cache/$site/_whitehall.csv"
tmpfile=$cache/${site}_tmp

if [ ! -d "$cache" ] ; then
    set -x
    mkdir -p "$cache"
    set +x
fi

if [ -n "$fetch" ]; then
    echo "Fetching $whitehall from production ..."
    mkdir -p $(dirname "$whitehall")
    [ -s "$whitehall" ] || rm -f "$whitehall"
    set -x
    curl -s -u "$user" "$whitehall_url" | tools/escape_commas_in_urls > "${whitehall}"
    set +x

    echo "Fetching mappings for $site ..."
    set -x
    tools/fetch_mappings.sh --fetch "$fetch_list" --cache-dir "$cache" "$site"
    set +x
fi


echo "Extracting mappings from Whitehall ..."
./tools/extract-whitehall-mappings.sh $host < $whitehall > $site_whitehall

echo "Finding list of source files ..."
set -x
all_files=$(perl -e 'print reverse <>' $fetch_list | awk -F, "\$1 == \"$site\" { print \"$cache/$site/\" \$2 \".csv\" }")
set +x

echo "Concatenating mappings ..."
./tools/csvcat.sh $site_whitehall $all_files > $all_file

echo "Eliminating 'clear_slug' deleted mappings from $all_file"
set -x
sed -i '/\/deleted-/d' $all_file


echo "Eliminating 'fabricatedurl' and 'placeholder' mappings from $all_file"
sed -i '/fabricatedurl/d' $all_file
sed -i '/placeholderunique/d' $all_file
set +x

echo "Munging and tidying mappings ..."
set -x
cat $all_file |
    ./munge/munge.rb $whitehall |
    ./tools/fold-mappings.rb |
    ./tools/choose-status.rb |
    ./munge/strip-empty-quotes-and-whitespace.rb |
    ./munge/reverse-csv.rb |
    ./tools/tidy_mappings.pl --trump $options > $tmpfile

./tools/tidy_mappings.pl --trump $options < $tmpfile > ${mappings}
set +x


echo "Validating mappings ..."
set -x
tools/validate_mappings.pl --host "$host" --whitelist "$whitelist" $options $mappings
set +x


echo "Done"
