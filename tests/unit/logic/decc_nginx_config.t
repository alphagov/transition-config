use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

# DECC location gone
my $decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/download/ukccs-kt-s8.0-sp-005-sh-interview-t',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/download/ukccs-kt-s8\\.0-sp-005-sh-interview-t/?\$ { return 410; }\n), 
    'Nginx config is as expected' );

$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/download/statistics/source/total/dukes1_1-1_3.xls',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/download/statistics/source/total/dukes1_1-1_3\\.xls/?\$ { return 410; }\n), 
    'Nginx config is as expected' );

$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/assests/decc/legislation/energybill/1010-green-deal-summary-proposal.pdf',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/assests/decc/legislation/energybill/1010-green-deal-summary-proposal\\.pdf/?\$ { return 410; }\n), 
    'Nginx config is as expected' );

$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/asse/default.aspx',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/asse/default\\.aspx/?\$ { return 410; }\n), 
    'Nginx config is as expected' );

# DECC location redirect

$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/en/content/cms/about/about.aspx',
	'New Url'	=> 'https://www.gov.uk/government/organisations/department-of-energy-climate-change/about',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/en/content/cms/about/about\\.aspx/?\$ { return 301 https://www.gov.uk/government/organisations/department-of-energy-climate-change/about; }\n), 
    'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/en/content/cms/about/acronyms/acronyms.aspx',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/en/content/cms/about/acronyms/acronyms\\.aspx/?\$ { return 301 https://gov.uk/test-page; }\n), 
    'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/en/content/cms/test/about/about.aspx',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/en/content/cms/test/about/about\\.aspx/?\$ { return 301 https://gov.uk/test-page; }\n), 
    'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/assets/decc/11/policy-legislation/emr/2210-emr-white-paper-full-version.pdfplanning',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'location',
	'No query string = location block' );
is( $config_line, qq(location ~* ^/assets/decc/11/policy-legislation/emr/2210-emr-white-paper-full-version\\.pdfplanning/?\$ { return 301 https://gov.uk/test-page; }\n), 
    'Nginx config is as expected' );


# DECC Map block gone
$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/challengeregistration/list.aspx?filter=allcountiesengland&country=england',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'gone_map',
	'query string & gone = gone map' );
is( $config_line, qq(~*filter=allcountiesengland&country=england 410;\n), 'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/consultations/default.aspx?status=0&area=0&pagenumber=9',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'gone_map',
	'query string & gone = gone map' );
is( $config_line, qq(~*status=0&area=0&pagenumber=9 410;\n), 'Nginx config is as expected' );

$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/default.aspx?lpa_id=y9507',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'gone_map',
	'query string & gone = gone map' );
is( $config_line, qq(~*lpa_id=y9507 410;\n), 'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/download/viewer?url=http://www.decc.gov.uk/assets/decc/11/consultation/ro-banding/5936-renewables-obligation-consultation-the-government.pdf',
	'New Url'	=> '',
	'Status'	=> 410, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'gone_map',
	'query string & gone = gone map' );
is( $config_line, qq(~*url=http://www.decc.gov.uk/assets/decc/11/consultation/ro-banding/5936-renewables-obligation-consultation-the-government.pdf 410;\n), 'Nginx config is as expected' );


# DECC Map block redirect

$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/challengeregistration/list.aspx?filter=allcountiesengland&country=scotland',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'redirect_map',
	'query string & redirect = redirect map' );
is( $config_line, qq(~*filter=allcountiesengland&country=scotland https://gov.uk/test-page;\n), 'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/consultations/default.aspx?status=1&area=0&pagenumber=9',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'redirect_map',
	'query string & redirect = redirect map' );
is( $config_line, qq(~*status=1&area=0&pagenumber=9 https://gov.uk/test-page;\n), 'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/default.aspx?lpa_id=y7707',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'redirect_map',
	'query string & redirect = redirect map' );
is( $config_line, qq(~*lpa_id=y7707 https://gov.uk/test-page;\n), 'Nginx config is as expected' );


$decc_mapping = { 
	'Old Url'	=> 'http://www.decc.gov.uk/download/viewer?url=http://www.decc.gov.uk/assets/decc/11/test/ro-banding/5936-renewables-obligation-consultation-the-government.pdf',
	'New Url'	=> 'https://gov.uk/test-page',
	'Status'	=> 301, 
};
( $host, $config_type, $config_line ) = $mappings->row_as_nginx_config($decc_mapping);
is( $host, 'www.decc.gov.uk', 
	'Host that config applies to is decc' );
is( $config_type, 'redirect_map',
	'query string & redirect = redirect map' );
is( $config_line, qq(~*url=http://www.decc.gov.uk/assets/decc/11/test/ro-banding/5936-renewables-obligation-consultation-the-government.pdf https://gov.uk/test-page;\n), 'Nginx config is as expected' );

done_testing();
