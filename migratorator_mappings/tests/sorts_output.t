use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

use constant NGINX_CONFIG => q(# invalid entry: status='301' old='http://www.direct.gov.uk/14-19prospectus' new=''
location = /16-19bursary { rewrite ^ https://www.gov.uk/1619-bursary-fund permanent; }
location = /16to19transport { rewrite ^ https://www.gov.uk/subsidised-college-transport-16-19 permanent; }
location = /2007budget { return 410; }
location = /en/Dl1/Directories/DG_074064 { return 410; }
location = /en/Dl1/Directories/DG_10011810 { return 410; }
location = /en/EducationAndLearning/14To19/MoneyToLearn/16to19bursary/index.htm { rewrite ^ https://www.gov.uk/1619-bursary-fund permanent; }
location = /en/EducationAndLearning/14To19/index.htm { rewrite ^ https://www.gov.uk/browse/education permanent; }
location = /en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943 { rewrite ^ https://www.gov.uk/working-tax-credit/overview permanent; }
location = /en/Nl1/Newsroom/DG_200994 { return 410; }
location = /en/Nl1/Newsroom/DG_201156 { return 410; }
location = /en/YoungPeople/DG_10034785 { return 410; }
);


my $mappings = Mappings->new( 'tests/not_sorted.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
ok( $configs->{'www.direct.gov.uk'} eq NGINX_CONFIG, 'nginx config is sorted' );
