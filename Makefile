all::	www.direct.gov.uk www.businesslink.gov.uk

#
#  build mappings for www.direct.gov.uk
#
www.direct.gov.uk:	directgov.csv
	#./mappings.sh $@ < mappings.csv > $@

www.businesslink.gov.uk:	businesslink.csv

# download mappings from Migratorator
directgov.csv:
	curl "https://${MIGRATORATOR_AUTH}@migratorator.production.alphagov.co.uk/mappings/filter/status:closed.csv" > $@

businesslink.csv:	bens.csv
	bens2csv.pl < bens.csv > $@

bens.csv:	
	curl "https://docs.google.com/spreadsheet/pub?key=0AprXhKI73WmwdHMwaW1aZVphOUJ1a3dTTGhJSFV5dGc&single=true&gid=0&output=csv" > $@

clean::
	rm -f www.direct.gov.uk directgov.csv www.businesslink.gov.uk businesslink.csv
