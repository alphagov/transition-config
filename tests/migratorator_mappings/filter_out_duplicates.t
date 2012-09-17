use strict;
use warnings;
use Test::More tests => 2;
use Mappings;



my $mappings = Mappings->new( 'tests/migratorator_mappings/contains_duplicates.csv' );
isa_ok( $mappings, 'Mappings' );

my $expected = {
    'www.businesslink.gov.uk' => {
        'duplicate_entry_error' => "http://www.businesslink.gov.uk/bdotg/action/detail?type=CAMPAIGN&site=220&furlname=innovation&furlparam=innovation&ref=&itemId=5001241747&domain=businesslink.gov.uk\nhttp://www.businesslink.gov.uk/bdotg/action/layer?=en&itemId=1086155234&lang=en&topicId=1081128739&type=RESOURCES\nhttp://www.businesslink.gov.uk/bdotg/action/layer?=en&itemId=1081128808&lang=en&topicId=1081128739&type=RESOURCES\n",
        'redirect_map'          => "~itemId=5001241747 https://www.gov.uk/browse/business#/intellectual-property;\n~topicId=1081128739 http://www.hmrc.gov.uk/agents/ct/online.htm;\n",
    },
    'www.direct.gov.uk' => {
        'duplicate_entry_error' => "http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943\n",
        'location' => "location = /en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943 { return 301 https://www.gov.uk/working-tax-credit/overview; }\n",
    },
};



my $configs = $mappings->entire_csv_as_nginx_config();
is_deeply( $expected, $configs, 'nginx config' );

use Data::Dumper;
print Dumper $configs;
