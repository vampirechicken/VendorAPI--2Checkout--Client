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

Version 0.0801

=cut

our $VERSION = '0.0801';

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

my %accept_mime_types = ( XML => 'application/xml', JSON => 'application/json' );

sub new {
   my $class = shift;
   my $username = shift;
   my $password = shift;
   my $accept   = shift;

   unless ( $username && $password) {
      return undef;
   }

   unless ( defined $accept && $accept =~ qr/^(?:XML|JSON)$/) {
      $accept = 'XML';
   }


   my $ua = LWP::UserAgent->new( agent => "VendorAPI::2Checkout::Client/${VERSION} " );
   $ua->credentials(VAPI_NETLOC, VAPI_REALM, $username, $password);
   return bless { ua => $ua, accept => $accept_mime_types{$accept}  }, $class;
}


=item $sales = $c->list_sales();

Retrieves the list of sales for the vendor

=cut

my $sort_col_re = qr/^(sale_id|date_placed|customer_name|recurring|recurring_declined|usd_total)$/;
my $sort_dir_re = qr/^(ASC|DESC)$/;

my %v = (
             sale_id => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             invoice_id => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             pagesize => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             cur_page => { type => SCALAR, regex => qw/^\d+$/ , untaint => 1, optional => 1, },
             customer_name => { type => SCALAR, regex => qw/^[-A-Za-z.]+$/ , untaint => 1, optional => 1, },
             customer_email => { type => SCALAR, regex => qw/^[-\w.+@]+$/ , untaint => 1, optional => 1, },
             customer_phone => { type => SCALAR, regex => qw/^[\d()-]+$/ , untaint => 1, optional => 1, },
             vendor_product_id => { type => SCALAR, regex => qw/^.+$/ , untaint => 1, optional => 1, },
             ccard_first6 => { type => SCALAR, regex => qw/^\d{6}$/ , untaint => 1, optional => 1, },
             ccard_last2 => { type => SCALAR, regex => qw/^\d\d$/ , untaint => 1, optional => 1, },
             date_sale_end  => { type => SCALAR, regex => qw/^\d{4}-\d\d-\d\d$/ , untaint => 1, optional => 1, },
             date_sale_begin  => { type => SCALAR, regex => qw/^\d{4}-\d\d-\d\d$/ , untaint => 1, optional => 1, },
             sort_col => { type => SCALAR, regex => $sort_col_re  , untaint => 1, optional => 1, },
             sort_dir => { type => SCALAR, regex => $sort_dir_re , untaint => 1, optional => 1, },
             active_recurrings => { type => SCALAR, regex => qr/^[01]$/, untaint => 1, optional => 1, },
             declined_recurrings => { type => SCALAR, regex => qr/^[01]$/, untaint => 1, optional => 1, },
             refunded => { type => SCALAR, regex => qr/^[01]$/, untaint => 1, optional => 1, },
        );

my $_profile = { map { $_ => $v{$_} } keys %v };

sub _accept_header();

sub list_sales {
   my $self = shift;
   my $uri = URI->new(VAPI_BASE_URI . '/list_sales');
   my %headers = ( Accept => $self->_accept() ); 

   my %input_params = validate(@_, $_profile);

   foreach my $param_name ( keys %input_params ) {
      $uri->query_param($param_name => $input_params{$param_name});
   }

   $self->_ua->get($uri, %headers);
}

=item  $sale = $c->detail_sale(sale_id => $sale_id);

Retrieves the details for the named sale.

=cut

my $_detail_profile = { map { $_ => $v{$_} } qw/sale_id invoice_id accept/ };

sub detail_sale {
   my $self = shift;

   my %p = validate(@_, $_detail_profile);

   unless ($p{sale_id} || $p{invoice_id}) {
      confess("detail_sale requires sale_id or invoice_id and received neither");
   }

   my $uri = URI->new(VAPI_BASE_URI . '/detail_sale');
   my %headers = ( Accept => $self->_accept() );

   if ($p{invoice_id} ) {
      $uri->query_param(invoice_id => $p{invoice_id});
   }
   else {
      $uri->query_param(sale_id => $p{sale_id});
   }

   $self->_ua->get($uri, %headers);
}


sub _accept {
   $_[0]->{accept};
};

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
