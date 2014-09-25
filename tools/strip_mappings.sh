# Usage tools/strip_mappings.sh target_file_to_strip
#
# From a file of URLs, strip URLs which we don't generally map in a transition,
# such as images.

urls_file=$1

for extension in $(cat tools/strip_list.txt);
do
    grep -i -v $extension $urls_file > uniquetempfilename &&
        mv uniquetempfilename $urls_file
done
