use strict;
use warnings;
use Test::More;
use Test::Alien;

use CInet::Alien::CaDiCaL;

alien_ok 'CInet::Alien::CaDiCaL';
ffi_ok { symbols => [ qw(ccadical_init ccadical_solve) ] };
run_ok([CInet::Alien::CaDiCaL->exe, '--version'])
    ->success
    ->out_like(qr/^([0-9.a-z]+)$/);

done_testing;
