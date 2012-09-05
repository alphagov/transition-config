use strict;
use warnings;
use Test::More tests=>10;
use Mappings;


my $mappings = Mappings->new( 'tests/migratorator_mappings/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $businesslink_redirect = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/detail?itemId=1081930072&type=PIP',
	'New Url'	=> 'https://www.gov.uk/get-information-about-a-company',
	'Status'	=> 301, 
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($businesslink_redirect);
ok( $redirect_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $redirect_type eq 'redirect_map',
	'If host is businesslink and type is redirect, type of nginx block is redirect_map'  );
ok( $redirect eq qq(~itemId=1081930072 https://www.gov.uk/get-information-about-a-company;\n),
    'Nginx config is as expected' );

my $businesslink_gone = { 
	'Old Url'	=> 'http://www.businesslink.gov.uk/bdotg/action/layer?&r.s=tl&r.l1=1073861197&r.lc=en&topicId=1073858975',
	'New Url'	=> '',
	'Status'	=> 410, 
};
my( $gone_host, $gone_type, $gone ) = $mappings->row_as_nginx_config($businesslink_gone);
ok( $gone_host eq 'www.businesslink.gov.uk', 
	'Host that config applies to is businesslink' );
ok( $gone_type eq 'gone_map',
	'If host is businesslink and type is gone, type of nginx block is gone_map'  );
ok( $gone eq qq(~topicId=1073858975 410;\n),
    'Nginx config is as expected' );


# Add (at least) the following two tests

#if it is a 301 with no new url and a someothercolumn of awaiting content then return 418

#if it's 301 with no blah and no awating content - what?


my $empty_row = undef;
my( $n_host, $no_type, $no_more ) = $mappings->row_as_nginx_config($empty_row);
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_type,                     'no type when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );


done_testing();
