#!/bin/sh

host=$1

curl -i -s -m 10 -L 'http://webarchive.nationalarchives.gov.uk/*/'$host |
    grep -o 'http[^"]*\d\d\d\d\d\d\d\d\d\d\d\d\d\d[^"]*' |
    tail -n 3

