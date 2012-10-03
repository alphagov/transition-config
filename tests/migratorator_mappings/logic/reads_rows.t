use strict;
use warnings;
use Test::More tests => 2;
use Mappings;

my $mappings = Mappings->new( 'tests/migratorator_mappings/row.csv' );
isa_ok( $mappings, 'Mappings' );

my $row = $mappings->get_row();
is_deeply(
    $row,
    {
      'Group'     => 'site source status destination reviewed',
      'Name'      => 'directgov crawler closed content no',
      'New Url'   => 'https://www.gov.uk/working-tax-credit/overview',
      'Notes'     => "28/06/12 AK - page added to Directgov 22/05/12. Hopefully it will have been fed through to GOV.UK so the guide can be reviewed.\r\n290612 LS - yes, WTC is being reworked and this info will be referenced",
      'Old Url'   => 'http://www.direct.gov.uk/en/MoneyTaxAndBenefits/TaxCredits/Gettingstarted/whoqualifies/DG_201943',
      'Status'    => 301,
      'Title'     => q('Incapacitated': what this means for Working Tax Credit : Directgov - Money, tax and benefits),
      'Whole Tag' => 'site:directgov source:crawler status:closed destination:content reviewed:no'
    }
);
