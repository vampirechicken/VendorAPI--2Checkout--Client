use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'VendorAPI::2Checkout::Client',
    AUTHOR              => q{Len Jaffe <lenjaffe@jaffesystems.com>},
    VERSION_FROM        => 'lib/VendorAPI/2Checkout/Client.pm',
    ABSTRACT_FROM       => 'lib/VendorAPI/2Checkout/Client.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'LWP'         => 0,
        'Params::Validate'  => 0,
    },
    BUILD_REQUIRES => {
        'Test::More'  => 0.87,
        'XML::Simple' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'VendorAPI-2Checkout-Client-*' },
);
