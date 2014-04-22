#!/bin/sh

target_host=$1

for host in $target_host $(echo $target_host | sed 's/^/www./; s/^www.www.//;')
do

echo '------------'
echo 'BEGIN EVALUATING '$host

echo '1. Checking DNS'
sh tools/dns_check.sh $host

echo '2. Checking homepage'
sh tools/host_check.sh $host

echo '3. Checking webarchive'
sh tools/webarchive_check.sh $host

echo 'END EVALUATING '$host

done
