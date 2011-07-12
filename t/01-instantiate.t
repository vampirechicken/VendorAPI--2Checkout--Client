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

is($tco->_accept(), 'application/xml', 'no accept param, default to XML');

$tco = VendorAPI::2Checkout::Client->new('len', 'somepwd', 'XML');
is($tco->_accept(), 'application/xml', 'accept param XML good');
$tco = VendorAPI::2Checkout::Client->new('len', 'somepwd', 'NOMATCH');
is($tco->_accept(), 'application/xml', 'bad accept param, default to XML');
$tco = VendorAPI::2Checkout::Client->new('len', 'somepwd', 'JSON');
is($tco->_accept(), 'application/json', 'accept param JSON good');
$tco = VendorAPI::2Checkout::Client->new('len', 'somepwd', undef);
is($tco->_accept(), 'application/xml', 'undef accept param, default to XML');


done_testing();
