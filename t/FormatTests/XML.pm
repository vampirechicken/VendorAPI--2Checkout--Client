package FormatTests::XML;
use parent 'FormatTests';

use strict;
use warnings;

use XML::Simple qw(:strict);

sub new {
   my $class = shift;
   return bless { }, $class;
}

sub num_sales {
   my $self = shift;
   scalar @{ $_[0]->{sale_summary} };
}

sub num_all_sales {
    my $self = shift;
    $_[0]->{page_info}[0]{total_entries}[0];
}

sub get_col {
    my $self = shift;
    my $sale = shift;
    my $col = shift;
    return $sale->{$col}[0];
}

sub to_hash {
   my $self = shift;
   my $content = shift;
   my $hash = XMLin($content, ForceArray => 1, KeyAttr => {});
   return $hash;
}




1
