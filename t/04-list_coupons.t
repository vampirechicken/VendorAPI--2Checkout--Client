#!perl -T

use strict;
use warnings;

use lib 't';

use Test::More ;
use List::MoreUtils qw(all pairwise);
use FormatTests::Factory;

BEGIN {
    use_ok( 'VendorAPI::2Checkout::Client' ) || print "Bail out!\n";
}



sub test_list_coupons {
   my $tco = shift;
   my $format_tests = shift;

    my $r = $tco->list_coupons();
    ok($r->is_success(), 'http 200');

    my $list = $format_tests->to_hash($r->content());
    my $num_coupons = $format_tests->num_coupons($list);

    if (defined $ENV{VAPI_HAS_COUPONS} && $ENV{VAPI_HAS_COUPONS} > 0 ) {
       ok($num_coupons > 0 , "got $num_coupons coupons");
    }

    return $num_coupons;
}




SKIP: {
    foreach my $format ( undef, 'XML', 'JSON'  ) {

       skip "VAPI_2CO_UID && VAPI_2CO_PWD not set in environment" , 3 unless $ENV{VAPI_2CO_UID} && $ENV{VAPI_2CO_PWD};

       my $tco = VendorAPI::2Checkout::Client->new( $ENV{VAPI_2CO_UID}, $ENV{VAPI_2CO_PWD}, $format );
       my $format_tests = FormatTests::Factory->get_format_tests($format);

       ok(defined $tco, "new: got object");
       isa_ok($tco,'VendorAPI::2Checkout::Client');

       my $num_coupons = test_list_coupons($tco, $format_tests);

    }
}  # SKIP

done_testing();
