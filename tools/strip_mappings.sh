
# Usage sh tools/strip_mappings.sh site abbreviation

mappings_file=$1

for extension in $(cat tools/strip_list.txt);
do
    grep -v -F $extension data/mappings/$mappings_file.csv > uniquetempfilename; && mv uniquetempfilename data/mappings/$mappings_file.csv
done
