#!/bin/bash

set -x

source sites.sh

echo DEPLOY_TO=$DEPLOY_TO


prove -l tests/integration/config_rules/     \
    	tests/integration/regression/   	 \
    	tools/test-log.pl


for site in ${REDIRECTED_SITES[@]}; do
	prove -l tests/unit/sources/${site}_valid_lines.t
	prove -l tests/redirects/$site/
done