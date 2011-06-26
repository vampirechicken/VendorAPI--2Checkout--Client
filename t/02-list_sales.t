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

ok(defined $tco, "new: got object");
isa_ok($tco,'VendorAPI::2Checkout::Client');

my $r = $tco->list_sales();
ok($r->is_success(), 'http 200');

my $list = XMLin($r->content(), ForceArray => 1, KeyAttr => {});

if (defined $ENV{VAPI_HAS_SALES} && $ENV{VAPI_HAS_SALES} > 0 ) {
   ok($list->{page_info}[0]{total_entries} > 0 , "got sales");
}

done_testing();
