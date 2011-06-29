use strict;
use warnings;
use Encode;
use Geo::Coder::Ovi;
use Test::More;

my $debug = $ENV{GEO_CODER_OVI_DEBUG};
unless ($debug) {
    diag "Set GEO_CODER_OVI_DEBUG to see request/response data";
}

my $geocoder = Geo::Coder::Ovi->new(
    debug    => $debug,
    compress => 0,
);
{
    my $address = '2001 North Fuller Avenue, Los Angeles, CA';
    my $location = $geocoder->geocode($address);
    is(
        $location->{properties}{addrCityName},
        'Los Angeles',
        "correct city for $address"
    );
}
{
    # Random foreign address with squiggles.
    my $address = qq(Neuturmstra\xDFe 5, 80331 M\xFCnchen, Germany);

    my $location = $geocoder->geocode($address, la=>'en');
    ok($location, 'latin1 bytes');
    is($location->{properties}{addrCountryName}, 'Germany', 'latin1 bytes');

    $location = $geocoder->geocode(decode('latin1', $address), la=>'en');
    ok($location, 'UTF-8 characters');
    is(
        $location->{properties}{addrCountryName}, 'Germany',
        'UTF-8 characters'
    );

    TODO: {
        local $TODO = 'UTF-8 bytes';
        $location = $geocoder->geocode(
            encode('utf-8', decode('latin1', $address)),
            la => 'de',
        );
        ok($location, 'UTF-8 bytes');
        is(
            $location->{properties}{addrCountryName}, 'Germany',
            'UTF-8 bytes'
        );
    }
}
{
    my $city = decode('latin1', qq(Schm\xF6ckwitz));
    my $location = $geocoder->geocode("$city, Berlin, Germany");
    is(
        $location->{properties}{addrDistrictName}, $city,
        'decoded character encoding of response'
    );
}

done_testing;
