use strict;
use warnings;
use Test::More;
use Mappings;


my $mappings = Mappings->new( 'tests/unit/test_data/first_line_good.csv' );
isa_ok( $mappings, 'Mappings' );

my $directgov_redirect = { 
    'Old Url'   => 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/',
    'New Url'   => 'https://www.gov.uk/working-tax-credit/overview',
    'Status'    => 301,
    'Suggested Link' => 'https://www.google.com',
};
my( $redirect_host, $redirect_type, $redirect, $suggested_map, $suggested_link ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
    'Host that config applies to is direct.gov' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/?\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx redirect does not contain double slashes' );

my $directgov_gone = { 
    'Old Url'   => 'http://www.direct.gov.uk/en/Dl1/',
    'New Url'   => '',
    'Status'    => 410, 
    'Suggested Link' => 'https://www.google.com',
};
( $redirect_host, $redirect_type, $redirect, $suggested_map, $suggested_link ) = $mappings->row_as_nginx_config($directgov_gone);
is( $redirect_host, 'www.direct.gov.uk', 
    'Host that config applies to is direct.gov' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/en/Dl1/?\$ { return 410; }\n),
    'Nginx gone does not contain double slashes' );
is( $suggested_map,
    'location_suggested_link',
    'Suggested links are bob' );
is( $suggested_link,
    qq(\$location_suggested_link['/en/Dl1'] = "<a href='https://www.google.com'>google.com</a>";\n),
    'Suggested link to Google');

done_testing();
