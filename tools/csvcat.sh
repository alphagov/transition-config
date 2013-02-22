#!/bin/sh

# csvcat.sh

# Concatenates csv files together, removing individual headers and replacing
# the correct header at the top of the file. Handles the lack of trailing newlines
# correctly.

set -e

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
