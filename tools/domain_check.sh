#!/bin/sh

host=$1

echo '------------'
echo 'EVALUATING '$host

echo '1. Checking DNS'
sh tools/dns_check.sh $host

echo '2. Checking homepage'
sh tools/host_check.sh $host

echo '3. Checking webarchive'
sh tools/webarchive_check.sh $host
