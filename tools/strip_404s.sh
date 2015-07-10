#!/bin/sh

# Usage tools/strip_404s.sh target_file_to_strip
#
# From a file of URLs, or stdin, strip URLs which return a HTTP 404 response

while read url
do
  curl --head --silent -o /dev/null --write-out '%{http_code} %{url_effective}\n' $url \
  | awk '$1 != 404 { print $2 }'
done < "${1:-/dev/stdin}"
