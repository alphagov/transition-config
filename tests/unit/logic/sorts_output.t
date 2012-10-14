use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

use constant NGINX_CONFIG => q(location = /16-19bursary { return 301 https://www.gov.uk/1619-bursary-fund; }
location = /16to19transport { return 301 https://www.gov.uk/subsidised-college-transport-16-19; }
location = /2007budget { return 410; }
location = /en/EducationAndLearning/14To19/MoneyToLearn/16to19bursary/index.htm { return 301 https://www.gov.uk/1619-bursary-fund; }
location = /en/EducationAndLearning/14To19/index.htm { return 301 https://www.gov.uk/browse/education; }
location ~* /en/(.*/)?dg_074064$ { return 410; }
location ~* /en/(.*/)?dg_10011810$ { return 410; }
location ~* /en/(.*/)?dg_10034785$ { return 410; }
location ~* /en/(.*/)?dg_200994$ { return 410; }
location ~* /en/(.*/)?dg_201156$ { return 410; }
location ~* /en/(.*/)?dg_201943$ { return 301 https://www.gov.uk/working-tax-credit/overview; }
);


my $mappings = Mappings->new( 'tests/unit/not_sorted.csv' );
isa_ok( $mappings, 'Mappings' );

my $configs = $mappings->entire_csv_as_nginx_config();
use Data::Dumper;
print Dumper $configs;
is( $configs->{'www.direct.gov.uk'}{'location'}, NGINX_CONFIG, 'nginx config is sorted' );
