package FormatTests::JSON;
use parent 'FormatTests';

use strict;
use warnings;

use JSON::Any;


sub new {
   my $class = shift;
   return bless { j => JSON::Any->new() }, $class;
}


sub num_sales {
   my $self = shift;
   return scalar @{ $_[0]->{sale_summary} };
}

sub num_all_sales {
    my $self = shift;
    return $_[0]->{page_info}[0]{total_entries}[0];
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
   my $hash = $self->j->decode($content);
   return $hash;
}




1
