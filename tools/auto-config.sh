# Script to auto-config a site

# Usage: from root directory
# sh tools/auto-config.sh mmo marine-management-organisation www.marinemanagement.org.uk '1st June 2014'

# Create site yaml
organisation=$2
domain=$3
abbrev=$1
# abbrev=$(echo $domain | sed 's/\./_/g')
filename='data/transition-sites/'$abbrev'.yml'
rake new_site[$abbrev,$organisation,$domain]

# Make updates to yml suitable for config
sed 's/www1\.www\.//' $filename |       # Config root as a likely alias
    grep -v 'www1' |
    grep -v 'www2' |
#    sed '/aliases/{N;s/^aliases:\n//;}' |

        # Eliminate global config (for now)
    grep -v 'global:' |

        # Comment query strings out in advance of proper configuration
    sed -E "s/(options:.*)/\# \1 # This site has not had full query string parameter analysis/" > tempymlfile &&
    mv tempymlfile $filename

# Run a sitemap and clean it of cruft
sh tools/sitemap.sh $domain
mv $domain.urls.txt $abbrev.urls.txt && rm -r $domain*
sh tools/strip_mappings.sh $abbrev.urls.txt

# Report on query strings for this site
sh tools/query_string_generator.sh $abbrev.urls.txt |
    sed 's/^/\# From Sitemap: /' >> $filename

# If no query strings, remove previous comment about query strings and any notes
qstring_param_count=$(grep 'From Sitemap' $filename | wc -l)
if [ $qstring_param_count == '1' ] ;
then
    grep -v 'From Sitemap' $filename | grep -v '\-\-query-string' > tempymlfile &&
    mv tempymlfile $filename
fi
