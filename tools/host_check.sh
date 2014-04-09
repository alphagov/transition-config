#!/bin/sh

host=$1

curl -I -s -m 10 -L 'http://'$host |
    grep 'HTTP\|Location'


