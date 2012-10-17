#!/bin/bash

export IFS=,·
{
	read url
	while read id url
	do
	       echo "<h2>$id: <a href="$url">$url</a></h2>"
	       echo "<iframe src="$url" width="80%" height="600px"></iframe>"

	done 
}  < data/lrc_transactions_source.csv > txns.html

