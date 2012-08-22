use strict;
use warnings;
use Test::More tests => 9;
use Mappings;

use constant REDIRECT_NGINX => qq(location = /en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943 { return 301 https://www.gov.uk/working-tax-credit/overview; }\n);
use constant GONE_NGINX     => qq(location = /en/Dl1/Directories/DG_10011810 { return 410; }\n);
use constant INVALID_NGINX  => qq(# invalid entry: status='301' old='http://www.direct.gov.uk/en/Nl1/Newsroom/DG_200994' new=''\n);



my $mappings = Mappings->new( 'tests/nginx.csv' );
isa_ok( $mappings, 'Mappings' );

my( $r_host, $redirect ) = $mappings->row_as_nginx_config();
my( $g_host, $gone     ) = $mappings->row_as_nginx_config();
my( $i_host, $invalid  ) = $mappings->row_as_nginx_config();
my( $n_host, $no_more  ) = $mappings->row_as_nginx_config();

ok( $r_host        eq 'www.direct.gov.uk', 'redirect host is directgov' );
ok( REDIRECT_NGINX eq $redirect,           'redirect' );
ok( $g_host        eq 'www.direct.gov.uk', 'gone host is directgov' );
ok( GONE_NGINX     eq $gone,               'gone' );
ok( $i_host        eq 'www.direct.gov.uk', 'invalid host is directgov' );
ok( INVALID_NGINX  eq $invalid,            'invalid' );
ok( !defined $n_host,                      'no host when EOF' );
ok( !defined $no_more,                     'no mapping when EOF' );
