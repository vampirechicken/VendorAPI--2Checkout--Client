#!perl -T

use strict;
use warnings;

use Test::More ;
use XML::Simple qw(:strict);

BEGIN {
    use_ok( 'VendorAPI::2Checkout::Client' ) || print "Bail out!\n";
}

sub num_sales {
   @{ $_[0]->{sale_summary} };
}

sub test_parameter {
   my ($ua, $param, $value) = @_;
   my $r = $ua->list_sales($param => $value);
   ok($r->is_success(), 'http 200');
   my $list = XMLin($r->content(), ForceArray => 1, KeyAttr => {});
   my $num_sales = num_sales($list);
   ok( $num_sales > 0, "got $num_sales for $value");
}


SKIP: {
    skip "VAPI_2CO_UID && VAPI_2CO_PWD not set in environment" , 4 unless $ENV{VAPI_2CO_UID} && $ENV{VAPI_2CO_PWD};

    my $tco = VendorAPI::2Checkout::Client->new( $ENV{VAPI_2CO_UID}, $ENV{VAPI_2CO_PWD} );

    ok(defined $tco, "new: got object");
    isa_ok($tco,'VendorAPI::2Checkout::Client');

    my $r = $tco->list_sales();
    ok($r->is_success(), 'http 200');
    my $list = XMLin($r->content(), ForceArray => 1, KeyAttr => {});
    my $num_all_sales = $list->{page_info}[0]{total_entries}[0];

    if (defined $ENV{VAPI_HAS_SALES} && $ENV{VAPI_HAS_SALES} > 0 ) {
       ok($num_all_sales > 0 , "got $num_all_sales sales");
    }

    # now try out some input parameters
    SKIP: {
       skip "list_sales input param tests require a vendor account with at leat 2 sales", $num_all_sales unless $num_all_sales >= 2;
        
       my ($value, $rv);
       my %param_test_data = (
           customer_name => 'carp',
           customer_email => 'carp',
           customer_phone => 614,
           vendor_product_id => 'Coffee',
           ccard_first6 => '443220',
           ccard_last2 => '38',
           date_sale_begin => '2010-12-15',
           date_sale_end => '2015-10-15',
       );
 

       foreach my $param ( keys %param_test_data ) {
          diag($param);
          $rv = test_parameter($tco, $param => $param_test_data{$param});
       }


       diag("Pagination");
       for (my $pagesize = 1; $pagesize <= $num_all_sales; $pagesize++) {
          my $num_full_pages = int($num_all_sales / $pagesize);
          my $partial_page = ( $num_full_pages * $pagesize != $num_all_sales);
          my $expected_pages = $num_full_pages + $partial_page;

          for (my $page_num = 1;$page_num <= $expected_pages; $page_num++) { 
             $r = $tco->list_sales(cur_page => $page_num, pagesize => $pagesize);
             ok($r->is_success(), 'http 200');
             my $list = XMLin($r->content(), ForceArray => 1, KeyAttr => {});
             my $num_sales = num_sales($list);

             if ( $page_num < $expected_pages || !$partial_page ) {
                is($num_sales, $pagesize, "got page $page_num of $expected_pages - $pagesize sales"); 
                next;
             }
             
             my $partial_size = $num_all_sales - ( $num_full_pages * $pagesize ) ;   
             is($num_sales, $partial_size, "got page $page_num of $expected_pages - $partial_size sales"); 
          } 
      
       }
    }  # SKIP



}  # SKIP

done_testing();
