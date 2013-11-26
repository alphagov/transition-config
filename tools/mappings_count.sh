
#Run from /redirector

file=data/mappings/$1.csv

for i in 301 410 418
do

	echo $i : $(grep $i $file | wc -l)
	
done