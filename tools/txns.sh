#!/bin/bash

export IFS=,·
while read id url
do
       echo "<h2>$id: <a href="$url"><\/a><\/h2>"
       echo "<iframe src="$url" width="80%" height="600px"><\/iframe>/"

done  < data/lrc_transactions_source.csv > txns.html

