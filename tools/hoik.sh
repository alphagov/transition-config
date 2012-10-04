#/bin/bash

#
#  hoik assets from DirectGov based on log files
#
cat /mnt/logs/processed/20120924/directgov-good.txt  | ( 
	mkdir -p static
	cd static

	awk '$1 ~ /(\.pdf|\.jpg|\.jpeg|\.gif|\.png|\.css|\.js)$/ { print $1 }' |

	while read url
	do
		wget -nv -N -x "$url"
	done
)
exit
