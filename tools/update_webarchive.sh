# Usage update_webarchive.sh siteabbreviation
#
# Automatically update the tna_timestamp for a given site by scraping The
# National Archives index page for the domain.

site=$1
getweb=$(find . | grep get_webarchive) # find the tool
yaml=$(find . | grep 'sites\/'$site'\.yml') # find the yaml
target=$(
	$getweb $(
		cat $yaml |
					grep host |
					sed 's/host: //'
					) |
		grep -o '\d\d\d\d\d\d\d\d\d\d\d\d\d\d'  # odd looking regex to work on both linux and mac unix
	)

sed 's/tna_timestamp.*/tna_timestamp: '$target'/' $yaml > temp &&
	mv -f temp $yaml
