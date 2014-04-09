#!/bin/sh

known_domains='known_domains.txt'

#Establish all the domains we know about from configuration

cat data/sites/* data/transition-sites/* $known_domains | grep -o -i -E '[a-zA-Z0-9-]*\.[a-zA-Z0-9-]*\.?[a-zA-Z0-9-]*\.?[a-zA-Z0-9-]*\.?[a-zA-Z0-9-]{1,61}\.\w{2,6}' | sort | uniq


