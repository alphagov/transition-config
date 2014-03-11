#Usage sh tools/query_string_generator.sh mylistofurls

#Given a list of URLS
list=$1

echo "Unique query string keys in this list of URLs"
grep -o 'http[^"]*' $list | grep -o '\?.*' $list | grep -o '[^=|&|\?]*=' | sed 's/=$//' | sort | uniq
