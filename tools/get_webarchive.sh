
#Usage sh get_webarchive.sh subdomain.topleveldomain.gov.uk

domain=$1

curl http://webarchive.nationalarchives.gov.uk/*/$domain |
  grep -o 'http[^"]*' |
  grep webarchive |
  grep -o '\d\d\d\d\d\d\d\d\d\d\d\d' |   # odd looking regex to work on both linux and mac unix
  sort |
  tail -1 |
  sed 's/^/Latest\ archive\ crawl\ for\ '$domain':\ /'

