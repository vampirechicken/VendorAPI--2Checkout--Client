package FormatTests;

# abstract superclass for FormatTest::{XML,JSON}

use strict;
use warnings;

my $_abstract_sub = sub {
   die "implement me";
};

sub num_sales     { $_abstract_sub->(); }
sub num_all_sales { $_abstract_sub->(); }
sub get_col       { $_abstract_sub->(); }
sub to_hash       { $_abstract_sub->(); }


1;
