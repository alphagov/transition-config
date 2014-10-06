mkdir cache
touch cache/known_domains
cat data/transition-sites/* | sed 's/^- /host: /' | grep host | awk '{ print $2 }' | sort | uniq > cache/known_domains
