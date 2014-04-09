#!/bin/sh

host=$1

[ -z "$DNS_SERVER" ] && DNS_SERVER=8.8.8.8

dig @$DNS_SERVER $host ANY | grep '^'$host
