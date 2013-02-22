#!/bin/sh

# csvcat.sh

# Concatenates csv files together, removing individual headers and replacing
# the correct header at the top of the file. Handles the lack of trailing newlines
# correctly.

set -e

usage() {
    echo "usage: $0 [opts] file1 [file2...]" >&2
    echo "    [-?|--help]                 print usage" >&2
    exit 1
}

while test $# -gt 0 ; do
    case "$1" in
    -\?|-h|--help) usage ;;
    --) break ;;
    -*) usage ;;
    esac
    break
done

(
  echo "old url,new url,status,source,row_number"
  for file in $@
  do
    set -x
    tail -n +2 "$file"
    set +x
    echo
  done
) | sed -e '/^$/d'
