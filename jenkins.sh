#!/bin/sh
set -e
mkdir -p dist

# run migratorator_mappings tests
prove -l tests/migratorator_mappings/*.t

# FIXME - MIGRATORATOR_AUTH

# DIRECTGOV
#   fetch directgov mappings
curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings/filter/status:closed.csv" > dist/directgov_mappings.csv
perl direct2csv.pl < dist/directgov_mappings.csv > dist/directgov.csv 2> dist/directgov_mapping_errors.txt

#   transform to nginx
# FIXME perl -Ilib create_mappings.pl dist/directgov.csv



# BUSINESSLINK
#   fetch businesslink mappings
curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > dist/businesslink_mappings.csv
perl bens2csv.pl < dist/businesslink_mappings.csv > dist/businesslink.csv

#   transform to nginx


exit














# 
# # www.direct.gov.uk:    directgov.csv
# 
# www.businesslink.gov.uk:  businesslink.csv
# 
# # directgov.csv:    mig_mappings.csv
# #   ./direct2csv.pl $@ < mig_mappings.csv > $@
# 
# # # download mappings from Migratorator
# # mig_mappings.csv:
# #   curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings/filter/status:closed.csv" > $@
# 
# businesslink.csv: bens.csv
#   ./bens2csv.pl < bens.csv > $@
# 
# # download mappings from Ben's spreadsheet in GoogleDocs - should eventually be Migratorator 
# bens.csv: 
#   curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > $@
# 
# clean::
#   rm -f www.direct.gov.uk directgov.csv www.businesslink.gov.uk businesslink.csv
# 







echo 'Get the latest master'
git checkout master
git pull

echo 'FETCH CSV of redirections from Migratorator'
curl -L 'https://betademo:nottobesharedoutsidegovernment@migratorator.production.alphagov.co.uk/mappings/filter/status:closed.csv' > mappings.csv

echo 'Use perl script to BUILD the nginx config (including sorting)'
prove -l tests/*.t
perl -Ilib create_mappings.pl mappings.csv > redirections

echo 'If there is a difference, then push the changes'
if [ $(git diff | wc -l) -ne 0 ];
then
    git add mappings.csv redirections
    git commit -m "Updating mappings and/or redirections as of `date`"
    git pull --rebase origin master
    git push origin master
fi

echo 'and DEPLOY new nginx config to the Redirector' 