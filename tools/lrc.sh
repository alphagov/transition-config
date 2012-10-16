#!/bin/bash

#
#  use output of process-lrc.sh to generate lrc test data in lrc.csv
#


mkdir -p dist

#
# clean
#
cat data/lrc-redirects-sorted.txt |
	sed -e '/^#/d' -e '/ 404 /d' -e 's/HTTPS:/https:/g' -e 's/HTTP:/http:/g' -e 's/,/%22/g' -e 's/"/%2C/g' -e 's/&amp;/\&/g' |

	# old status new count
	awk '$1 == $3 || $3 == "" { print $1 " " 200 " " $4 }
		$1 != $3 { print $1 " 301 " $4 " " $3 }' | perl -ne '

		my ($url, $status, $count, $new) = split(/\s+/);

		my %url_map = (
			"http://lrc.businesslink.gov.uk" => "",
			"http://lrc.businesslink.gov.uk/" => "",
			"http://lrc.businesslink.gov.uk/lrc/lrcHeader" => "",
		);

		if (defined $map{$url_map}) {
			$new = $map{$url_map};
			$status = $new ? 301 : 410;
		}

		my %new_map = (
		
			"https://online.businesslink.gov.uk/bdotg/action/detail?itemId=1083081245&type=PIP&site=1000" => "https://www.gov.uk/file-your-company-accounts-and-tax-return",
			"https://online.businesslink.gov.uk/bdotg/action/detail?itemId=1082653972&type=PIP&site=1000" => "http://www.hmrc.gov.uk/paye/file-or-pay/fileonline/",
			"http://www.businesslink.gov.uk/bdotg/action/home?domain=online.businesslink.gov.uk&target=http://online.businesslink.gov.uk/" => "https://www.gov.uk/transaction-finished",
		);


		if (defined $new_map{$new}) {
			$new = $new_map{$new};
			$status = $new ? 301 : 410;
		} elsif ($new =~ /\btype=CROSSSELL\b/) {
			$new = "https://www.gov.uk/transaction-finished";
			$status = 301;
		}

		print "$url $status $count $new\n";

	' | {
		echo "Old Url,New Url,Status,Count,Whole Tag"
		awk '{ print "\"" $1 "\"," $4 "," $2 "," $3 ",Closed" }'
	} > dist
