#!perl -T

use strict;
use warnings;

use lib 't';

use Test::More ;
use FormatTests::Factory;

BEGIN {
    use_ok( 'VendorAPI::2Checkout::Client' ) || print "Bail out!\n";
}

sub test_list_payments {
   my $tco = shift;
   my $format_tests = shift;

    my $r = $tco->list_payments();
    ok($r->is_success(), 'http 200');

    my $list = $format_tests->to_hash($r->content());
    my $num_payments = $format_tests->num_payments($list);

    if (defined $ENV{VAPI_HAS_PAYMENTS} && $ENV{VAPI_HAS_PAYMENTS} > 0 ) {
       ok($num_payments > 0 , "got $num_payments payments");
    }

    return $num_payments;
}


SKIP: {
    foreach my $format ( undef, 'XML', 'JSON'  ) {

       skip "VAPI_2CO_UID && VAPI_2CO_PWD not set in environment" , 3 unless $ENV{VAPI_2CO_UID} && $ENV{VAPI_2CO_PWD};

       my $tco = VendorAPI::2Checkout::Client->new( $ENV{VAPI_2CO_UID}, $ENV{VAPI_2CO_PWD}, $format );
       my $format_tests = FormatTests::Factory->get_format_tests($format);

       ok(defined $tco, "new: got object");
       isa_ok($tco,'VendorAPI::2Checkout::Client');

       my $num_payments = test_list_payments($tco, $format_tests);

    }
}  # SKIP

done_testing();
