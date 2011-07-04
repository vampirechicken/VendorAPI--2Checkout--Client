package VendorAPI::2Checkout::Client;

use 5.006;
use strict;
use warnings;

use LWP::UserAgent;
use Params::Validate qw(:all);
use Carp qw(confess);
use URI;
use URI::QueryParam;

use Data::Dumper;

=head1 NAME

VendorAPI::2Checkout::Client - an OO interface to the 2Checkout.com Vendor API

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.04';

use constant {
     VAPI_BASE_URI => 'https://www.2checkout.com/api/sales',
     VAPI_REALM    => '2CO API',
     VAPI_NETLOC   => 'www.2checkout.com:443',
};

=head1 SYNOPSIS

    use VendorAPI::2Checkout::Client;

    my $tco = VendorAPI::2Checkout::Client->new($username, $password);
    $sales = $tco->list_sales();

    $sale = $tco->detail_sale(sale_id => 1234554323);

    ...

=head1 DESCRIPTION

This module is an OO interface to the 2Checkout.com Vendor API.

This modules uses Params::Validate which likes to die() when the parameters do not pass validation, so
wrap your code in evals, etc.

Presently only implements list_sales (no params), and detail_sale( sale_id => $sale_id ).

Return data is in XML. Requesting JSON not implemented yet.

Please refer to L<2Checkout's Back Office Admin API Documentation|http://www.2checkout.com/documentation/api> 
for input parameters and expexted return values.

=head1 CONSTRUCTORS AND METHODS

=over 4

=item $c = VendorAPI::2Checkout::Client->new($username, $password)

Contructs a new C<VendorAPI::2Checkout::Client> object to comminuncate with the 2Checkout Back Office Admin API.
You must pass your Vendor API username and password or the constructor will return undef;

=cut

sub new {
   my $class = shift;
   my $username = shift;
   my $password = shift;
   
   unless ( $username && $password) {
      return undef;
   }

   my $ua = LWP::UserAgent->new( agent => "VendorAPI::2Checkout::Client/${VERSION} " );
   $ua->credentials(VAPI_NETLOC, VAPI_REALM, $username, $password);
   return bless { ua => $ua }, $class;
}


=item $sales = $c->list_sales();

Retrieves the list of sales for the vendor

=cut
my $v = { 
             id => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             pagesize => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             cur_page => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             accept   => { type => SCALAR, regex => qr/(?:json|xml)/i, untaint => 1, optional => 1 },
        };


my $_profile = { map { $_ => $v->{$_} } qw/sale_id invoice_id pagesize cur_page accept/ };

sub list_sales {
   my $self = shift;

   my $uri = URI->new(VAPI_BASE_URI . '/list_sales');
   my %p = validate(@_, $_profile);


   my $headers;
   $headers->{'content-type'} = 'text/plain;charset=utf-8';
   if ($p{accept} && lc($p{accept}) eq 'json') {
      $headers->{'Accept:'} = 'application/json';
      delete $p{accept};
   }

   foreach my $k ( keys %p ) {
      $uri->query_param($k => $p{$k});
   }

   if (defined $headers ) {
      $self->_ua->get($uri, %$headers);
   }
   else {
      $self->_ua->get($uri);
   }
}

=item  $sale = $c->detail_sale(sale_id => $sale_id);

Retrieves the details for the named sale.  

=cut
my $_detail_profile = { map { $_ => $v->{$_} } qw/sale_id invoice_id accept/ };

sub detail_sale {
   my $self = shift;
   my $headers;
   
   my %p = validate(@_, $_detail_profile);

   unless ($p{sale_id} || $p{invoice_id}) {
      confess("detail_sale requires sale_id or invoice_id and received neither");
   } 

   my $uri = URI->new(VAPI_BASE_URI . '/detail_sale');

   if ($p{invoice_id} ) {
      $uri->query_param(invoice_id => $p{invoice_id});
   }
   else { 
      $uri->query_param(sale_id => $p{sale_id});
   }

   if ($p{accept} && lc($p{accept}) eq 'json') {
      $headers->{'Accept:'} = 'application/json';
   }

   if (defined $headers ) {
      $self->_ua->get($uri, %$headers);
   }
   else {
      $self->_ua->get($uri);
   }
}


sub _ua { 
   $_[0]->{ua}; 
};



=back

=head1 AUTHOR

Len Jaffe, C<< <lenjaffe at jaffesystems.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-vendorapi-2checkout-client at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=VendorAPI-2Checkout-Client>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc VendorAPI::2Checkout::Client


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=VendorAPI-2Checkout-Client>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/VendorAPI-2Checkout-Client>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/VendorAPI-2Checkout-Client>

=item * Search CPAN

L<http://search.cpan.org/dist/VendorAPI-2Checkout-Client/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Len Jaffe.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of VendorAPI::2Checkout::Client
