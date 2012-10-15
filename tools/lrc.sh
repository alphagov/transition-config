#!/bin/bash

#
#  use output of process-lrc.sh to generate lrc_map.conf and test data in lrc.csv
#
#  runable by jenkins.sh, but could be refactored to follow style used for bl mappings
#

input=data/lrc-redirects-sorted.txt

mkdir -p dist

#
# clean
#
cat $input |
	sed -e '/^#/d' -e '/ 404 /d' -e 's/HTTPS:/https:/g' -e 's/HTTP:/http:/g' -e 's/,/%22/g' -e 's/"/%2C/g' -e 's/&amp;/\&/g' |

	# old status new count
	awk '$1 == $3 || $3 == "" { print $1 " " 200 " " $4 }
		$1 != $3 { print $1 " 301 " $4 " " $3 }' | perl -ne '

		my ($url, $status, $count, $new) = split(/\s+/);

		my %map = {
			"http://lrc.businesslink.gov.uk" => "",
			"http://lrc.businesslink.gov.uk/" => "",
			"http://lrc.businesslink.gov.uk/lrc/lrcHeader" => "",
			"https://online.businesslink.gov.uk/bdotg/action/detail?itemId=1082653972&type=PIP&site=1000" => "http://www.hmrc.gov.uk/paye/file-or-pay/fileonline/",
			"lrc.businesslink.gov.uk/lrc/lrcReturn?xgovs9k=voa&xgovr3h=r2010" => "XXXXXXXXXXXXXX",
			"http://lrc.businesslink.gov.uk/lrc/lrcOutbound?xgovs9k=coho&xgovr3h=winc&xgovc8h=1000" => "https://ewf.companieshouse.gov.uk/govlink?xgovk3w=bl1000&xgovf0p=|xgovs9k=coho|xgovr3h=winc|xgovc8h=1000|xgovk3w=bl1000|&xgovd2v=en&xgovj6d=452734a110d6d1a1d0893be4ee96cab3ffde1a4c",
			"http://lrc.businesslink.gov.uk/lrc/lrcOutbound?xgovs9k=coho&xgovr3h=winc&xgovc8h=191" => "https://ewf.companieshouse.gov.uk/govlink?xgovk3w=bl191&xgovf0p=|xgovs9k=coho|xgovr3h=winc|xgovc8h=191|xgovk3w=bl191|&xgovd2v=en&xgovj6d=e3e20836ed760546114de88193cb82c034f40f43",
		};


		if ($map{$url}) {
			$new = $map{url};
			$status = $new ? 301 : 404;
		} elsif ($new =~ /\btype=CROSSSELL\b/) {
			$new = "https://www.gov.uk/transaction-finished";
			$status = 301;
		} elsif ($new eq "http://www.businesslink.gov.uk/bdotg/action/home?domain=online.businesslink.gov.uk&target=http://online.businesslink.gov.uk/") {
			$new = "https://www.gov.uk/transaction-finished";
			$status = 301;
		}

		print "$url $status $count $new\n";

	' > dist/lrc-cleaned.txt

# mappings

	cat dist/lrc-cleaned.txt | {
		echo "~type=CROSSSELL https://www.gov.uk/transaction-finished;";

		perl -ne '
		use URI;
		use URI::QueryParam;

		# http://lrc.businesslink.gov.uk/lrc/lrcOutbound?xgovs9k=voa&xgovr3h=efor&xgovc8h=1000

		my ($url, $status, $count, $new) = split(/\s+/);
		my $uri = URI->new($url);


		if ($status =~ /^3/) {

			# TBD: possibly denormalise combinations for unordered multiple parameters
			# print "~\\bxgovr3h=${xgovr3h}\\b.*\\b\\bxgovs9k=${xgovs9k}|\\bxgovs9k=${xgovs9k}\\b.*\\b\\bxgovr3h=${xgovr3h} $new;\n";

			if ($new =~ /CROSSSELL/) {
				next;
			}

			my $sep = "~";
			my $expr = "";

			if ($url =~ /(xgovs9k=)?.*(xgovr3h)?/) {
				foreach my $param (qw( xgovs9k xgovr3h xgovc8h xgovk3w )) {
					my $value = $uri->query_param($param);
					$expr .= "$sep\\b${param}=${value}\\b" if (defined $value);
					$sep = ".*";
				}
			} elsif ($url =~ /(xgovr3h=)?.*(xgovs9k)?/) {
					my $value = $uri->query_param($param);
					$expr .= "$sep\\b${param}=${value}\\b" if (defined $value);
					$sep = ".*";
			}

			if ($expr) {
				print "$expr $new;\n"
			}
		}
	' 
} | sort | uniq > dist/lrc_map.conf

# CSV

cat dist/lrc-cleaned.txt | {
	echo "Old Url,New Url,Status,Count,Whole Tag"
	awk '{ print "\"" $1 "\"," $4 "," $2 "," $3 ",Closed" }'
} > dist/lrc.csv
