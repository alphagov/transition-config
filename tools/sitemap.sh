
target=$1
domain=$(echo $target | sed 's/\/.*//g' )
subdir=$(echo $target | sed 's/^[^\/]*//' | sed 's/[^\/]*\///' | sed 's/\/$//' )
mkdir -p $domain

if [ $subdir ]
	then
	echo "Spidering a subdirectory $domain/$subdir"
		wget --no-parent -I $subdir -r -l0 -x -k --reject=wmv,WMV,mpg,MPG,pdf,PDF,jpg,JPG,gif,GIF,png,PNG,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,ppt,PPT,pptx,PPTX -t2 -nd -P $domain.$subdir -e robots=off -o $domain.$subdir.log $target
    cat $domain.$subdir/* >> $domain.$subdir.log
		grep -F $domain $domain.$subdir.log | grep -o $"http:\/\/[^\ \"\<\>\']*" | sed 's/\/$//' | sort | uniq > $domain.$subdir.urls.txt
	else
		echo "Spidering a whole domain $domain"
		wget --no-parent -r -l0 -x -k --reject=wmv,WMV,mpg,MPG,pdf,PDF,jpg,JPG,gif,GIF,png,PNG,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,ppt,PPT,pptx,PPTX -t2 -nd -P $domain -e robots=off -o $domain.log $target
	  cat $domain/* >> $domain.log
	  grep -F $domain $domain.log | grep -o $"http:\/\/[^\ \"\<\>\']*" | sed 's/\/$//' | sort | uniq > $domain.urls.txt

fi

echo "DONE SPIDERING"


