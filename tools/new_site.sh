# $1 = name of site
# $2 = domain of site

site="data/sites/$1.yml"
mappings="data/mappings/$1.csv"
tests="data/tests/$2.csv"

touch $site
echo "---" >> $site
echo "site: $1" >> $site
echo "host: $2" >> $site
echo "redirection_date: 21st February 2013 	# Full text date here" >> $site
echo "tna_timestamp: 20130128101412 				# Best TNA timestamp here" >> $site
echo "title: Cabinet Office									# Title of organisation here" >> $site
echo "furl: www.gov.uk/dclg									# Furl for print display here" >> $site
echo "homepage: https://www.gov.uk/government/organisations/department-for-communities-and-local-government" >> $site
echo "																			# Organisation landing page here" >> $site
echo "css: cabinet-office										# Appropriate CSS here" >> $site
echo "aliases:															# Aliases for $2 domain here" >> $site
echo "  - www.dclg.gov.uk" >> $site
echo "  - www.communities.gov.uk" >> $site
echo "options: --query-string title:attachment" >> $site
echo "---" >> $site
echo "# Remove comments and placeholder data before committing" >> $site
echo "# Add tests file for each additional alias" >> $site

touch $mappings
echo "Old URL,New URL,Status" >> $mappings

touch $tests
echo "Old URL,New URL,Status" >> $tests
