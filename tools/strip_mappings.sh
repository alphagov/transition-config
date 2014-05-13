
# Usage sh tools/strip_mappings.sh target_file_to_strip

mappings_file=$1

for extension in $(cat tools/strip_list.txt);
do
    grep -i -v -F $extension $mappings_file > uniquetempfilename &&
        mv uniquetempfilename $mappings_file
done
