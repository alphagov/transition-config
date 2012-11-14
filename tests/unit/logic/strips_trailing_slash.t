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
};
my( $redirect_host, $redirect_type, $redirect ) = $mappings->row_as_nginx_config($directgov_redirect);
is( $redirect_host, 'www.direct.gov.uk', 
    'Host that config applies to is improve.businesslink' );
is( $redirect_type, 'location',
    'Type is location'  );
is( $redirect, 
    qq(location ~* ^/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/?\$ { return 301 https://www.gov.uk/working-tax-credit/overview; }\n),
    'Nginx redirect does not contain double slashes' );

done_testing();
