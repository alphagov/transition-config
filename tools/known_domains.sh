# Usage:
#
#   from root directory
#   tools/known_domains.sh
#
# Outputs list of all hosts and aliases to to a textfile in cache/

mkdir cache
touch cache/known_domains
cat data/transition-sites/* | grep -v '\- path: ' | sed 's/^- /host: /' | grep host | grep '\.' | awk '{ print $2 }' | sort | uniq > cache/known_domains
