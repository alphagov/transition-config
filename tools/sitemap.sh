
target=$1
domain=$(echo $target | sed 's/\/.*//g' )
subdir=$(echo $target | sed 's/^[^\/]*//' | sed 's/[^\/]*\///' | sed 's/\/$//' )
mkdir -p $domain

if [ $subdir ]
	then
	echo "Spidering a subdirectory $domain/$subdir"
		wget --no-parent -I $subdir -r -l0 -x -k --reject=pdf --reject=PDF --reject=jpg --reject=JPG --reject=gif --reject=GIF -t2 -nd -P $domain.$subdir -e robots=off -o $domain.$subdir.log $target
    cat $domain.$subdir/* >> $domain.$subdir.log
		grep -F $domain $domain.$subdir.log | grep -o 'http:\/\/[^\ \"\(\)\<\>]*' | sed 's/\/$//' | sort | uniq > $domain.$subdir.urls.txt
	else
		echo "Spidering a whole domain $domain"
		wget --no-parent -r -l0 -x -k --reject=pdf --reject=PDF --reject=jpg --reject=JPG --reject=gif --reject=GIF -t2 -nd -P $domain -e robots=off -o $domain.log $target
	  cat $domain/*htm* >> $domain.log
	  grep -F $domain $domain.log | grep -o 'http:\/\/[^\ \"\(\)\<\>]*' | sed 's/\/$//' | sort | uniq > $domain.urls.txt

fi

echo "DONE SPIDERING"


