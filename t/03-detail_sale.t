#!perl -T

use strict;
use warnings;

use Test::More ;
use XML::Simple qw(:strict);

BEGIN {
    use_ok( 'VendorAPI::2Checkout::Client' ) || print "Bail out!\n";
    $ENV{VAPI_2CO_UID} && $ENV{VAPI_2CO_PWD} || BAIL_OUT( "VAPI_2CO_UID && VAPI_2CO_PWD not set in environment" );
}

my $tco = VendorAPI::2Checkout::Client->new( $ENV{VAPI_2CO_UID}, $ENV{VAPI_2CO_PWD} );
my $details;
my $sale_id;

SKIP:  {
   skip "VAPI_HAS_SALES not set in environment. No sales to retrieve", 2 unless (defined $ENV{VAPI_HAS_SALES} && $ENV{VAPI_HAS_SALES} > 0) ;

   my $r = $tco->list_sales();
   my $salelistxml = XMLin($r->content(), ForceArray => 1, KeyAttr => {});
   my $sale =  $salelistxml->{sale_summary}[0];
   $sale_id =  $sale->{sale_id}[0];
   
   $details = $tco->detail_sale(sale_id => $sale_id);
   ok($details->is_success(), 'got detail');
   my $salexml = XMLin($details->content(), ForceArray => 1, KeyAttr => {});
   is( $salexml->{sale}[0]->{invoices}[0]->{sale_id}[0], $sale_id, "sale detail looks ok");
}

$sale_id = 42;  # should fail;
$details = $tco->detail_sale(sale_id => $sale_id);
ok($details->is_error, "got an error");
my $errorxml = XMLin($details->content(), ForceArray => 1, KeyAttr => {});
is($errorxml->{errors}[0]{code}[0], 'RECORD_NOT_FOUND', "Sale $sale_id not found");


done_testing();
