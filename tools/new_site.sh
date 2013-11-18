# $1 = name of site
# $2 = domain of site

site="data/sites/$1.yml"
mappings="data/mappings/$1.csv"
tests="data/tests/$2.csv"

touch $site
echo "---" >> $site
echo "site: $1" >> $site
echo "host: $2" >> $site
echo "redirection_date: 21st February 2013" >> $site
echo "tna_timestamp: 20130128101412" >> $site
echo "title: Department Name" >> $site
echo "furl: www.gov.uk/$1" >> $site
echo "homepage: https://www.gov.uk/government/organisations/$1" >> $site
echo "css: cabinet-office" >> $site
echo "aliases:" >> $site
echo "  - www.dclg.gov.uk" >> $site
echo "  - www.communities.gov.uk" >> $site
echo "options: --query-string title:attachment" >> $site
echo "---" >> $site

touch $mappings
echo "Old Url,New Url,Status" >> $mappings

touch $tests
echo "Old Url,New Url,Status" >> $tests
echo "http://$2,https://www.gov.uk/government/organisations/replace-org-slug-$1,301" >> $tests
