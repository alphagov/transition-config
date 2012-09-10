#!/bin/sh

set -eu

# FIXME - this should be set by jenkins
export DEPLOY_TO=preview

SERVER="${DEPLOY_TO}-redirector"

SSH_CONFIG="-F ../alphagov-deployment/ssh_config"

# redirector site configurations
# scp -F ../ssh_config ./nginx_configs/*.conf "$SERVER":/etc/nginx/sites-available
scp $SSH_CONFIG ./dist/www.*.conf "$USER@$SERVER":/var/apps/redirector
scp $SSH_CONFIG ./nginx_configs/redirections "$USER@$SERVER":/var/apps/redirector

ssh $SSH_CONFIG "$SERVER" sudo /etc/init.d/nginx reload
