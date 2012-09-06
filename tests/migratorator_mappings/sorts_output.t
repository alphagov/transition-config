use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

use constant NGINX_CONFIG => q(location = /16-19bursary { return 301 https://www.gov.uk/1619-bursary-fund; }
location = /16to19transport { return 301 https://www.gov.uk/subsidised-college-transport-16-19; }
location = /2007budget { return 410; }
location = /en/Dl1/Directories/DG_074064 { return 410; }
location = /en/Dl1/Directories/DG_10011810 { return 410; }
location = /en/EducationAndLearning/14To19/MoneyToLearn/16to19bursary/index.htm { return 301 https://www.gov.uk/1619-bursary-fund; }
location = /en/EducationAndLearning/14To19/index.htm { return 301 https://www.gov.uk/browse/education; }
location = /en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943 { return 301 https://www.gov.uk/working-tax-credit/overview; }
location = /en/Nl1/Newsroom/DG_200994 { return 410; }
location = /en/Nl1/Newsroom/DG_201156 { return 410; }
location = /en/YoungPeople/DG_10034785 { return 410; }
);


my $mappings = Mappings->new( 'tests/migratorator_mappings/not_sorted.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
use Data::Dumper;
print Dumper $configs;
ok( $configs->{'www.direct.gov.uk'}{'location'} eq NGINX_CONFIG, 'nginx config is sorted' );
