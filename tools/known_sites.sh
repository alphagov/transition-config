#!/bin/sh

sitefocus=$1
known_domains='known_domains.txt'

#Establish all the domains we know about from configuration

cat data/sites/*$sitefocus* data/transition-sites/*$sitefocus* |
    grep -o -i -E '[a-zA-Z0-9-]*\.[a-zA-Z0-9-]*\.?[a-zA-Z0-9-]*\.?[a-zA-Z0-9-]*\.?[a-zA-Z0-9-]{1,61}\.\w{2,6}' |
    grep -v 'www.gov.uk' |
    sort | uniq


