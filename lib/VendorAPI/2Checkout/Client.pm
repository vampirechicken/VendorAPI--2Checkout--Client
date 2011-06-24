package VendorAPI::2Checkout::Client;

use 5.006;
use strict;
use warnings;

=head1 NAME

VendorAPI::2Checkout::Client - an OO interface to the 2Checkout.com Vendor API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use VendorAPI::2Checkout::Client;

    my $tco = VendorAPI::2Checkout::Client->new($username, $password);
    $tco->list_sales([$format]);

    ...

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
   my $class = shift;
   my $username = shift;
   my $password = shift;
   
   unless ( $username && $password) {
      return undef;
   }

   return bless { uid => $username, pwd => $password }, $class;
}

=head2 list_sales

=cut

sub list_sales {
}

=head2 detail_sale

=cut

sub detail_sale {
}

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
