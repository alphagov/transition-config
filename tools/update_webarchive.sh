
#Usage sh update_webarchive.sh subdomain.topleveldomain.gov.uk

site=$1
getweb=$(find . | grep get_webarchive) # find the tool
yaml=$(find . | grep $site.yml) # find the yaml
target=$(
	sh $getweb $(
		cat $yaml |
					grep host |
					sed 's/host: //'
					) |
		grep -o '\d\d\d\d\d\d\d\d\d\d\d\d\d\d'  # odd looking regex to work on both linux and mac unix
	)

sed 's/tna_timestamp.*/tna_timestamp: '$target'/' $yaml > temp &&
	mv -f temp $yaml
