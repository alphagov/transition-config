#!/bin/sh

set -eu

# FIXME - this should be set by jenkins
export DEPLOY_TO=preview

SERVER="${DEPLOY_TO}-redirector"

# redirector site configurations
# scp -F ../ssh_config ./nginx_configs/*.conf "$SERVER":/etc/nginx/sites-available
scp -F ../ssh_config ./dist/www.*.conf "$SERVER":/var/apps/redirector

ssh -F ../ssh_config "$SERVER" sudo /etc/init.d/nginx reload
