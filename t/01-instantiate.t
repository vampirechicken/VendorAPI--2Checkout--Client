#!perl -T

use strict;
use warnings;

use Test::More ;

BEGIN {
    use_ok( 'VendorAPI::2Checkout::Client' ) || print "Bail out!\n";
}

my $tco = VendorAPI::2Checkout::Client->new();
ok(!defined $tco, "new: username and password are required - got undef");

$tco = VendorAPI::2Checkout::Client->new('len');
ok(!defined $tco, "new: username and password are required - got undef");

$tco = VendorAPI::2Checkout::Client->new('len', 'somepwd');
ok(defined $tco, "new: username and password are required - got object");

isa_ok($tco,'VendorAPI::2Checkout::Client');
can_ok($tco, 'list_sales');
can_ok($tco, 'detail_sale');

done_testing();
