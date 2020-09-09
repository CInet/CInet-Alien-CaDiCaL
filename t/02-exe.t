use strict;
use warnings;
use autodie;
use Test::More;

use IPC::Run3;
use Path::Tiny;
use CInet::Alien::CaDiCaL qw(cadical);

# AIM test set by Kazuo Iwama, Eiji Miyano and Yuichi Asahiro,
# found through https://www.cs.ubc.ca/~hoos/SATLIB/benchm.html

my $aim = path('t', 'aim');
for my $cnf ($aim->children(qr/cnf$/)) {
    my $expected = !!($cnf =~ /yes/);
    run3 [cadical, $cnf], \undef, \undef, \undef;
    my $got = ($? >> 8);
    die "cadical returned $got" unless $got == 10 or $got == 20;
    is(($got == 10), $expected, "$cnf ok");
}

done_testing;
