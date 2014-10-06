# Usage:
#
#   from redirector root directory
#   tools/known_domains.sh
#
# Outputs list of all hosts and aliases to to a textfile in redirector/cache

mkdir cache
touch cache/known_domains
cat data/transition-sites/* | sed 's/^- /host: /' | grep host | awk '{ print $2 }' | sort | uniq > cache/known_domains
