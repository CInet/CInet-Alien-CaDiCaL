use strict;
use warnings;
use autodie;
use Test::More;

use IPC::Run3;
use Path::Tiny;
use CInet::Alien::CaDiCaL;

package CaDiCaL::Solver {
    use FFI::Platypus;

    my $ffi = FFI::Platypus->new(api => 1);
    $ffi->lib(CInet::Alien::CaDiCaL->dynamic_libs);
    $ffi->mangler(sub { 'ccadical_' . shift });

    $ffi->type('object(CaDiCaL::Solver)' => 'solver_t');
    $ffi->attach(['init' => 'new'] => [] => 'solver_t');
    $ffi->attach(['release' => 'DESTROY'] => ['solver_t'] => 'void');
    $ffi->attach('add' => ['solver_t', 'int'] => 'void');
    $ffi->attach('solve' => ['solver_t'] => 'int');
}

# AIM test set by Kazuo Iwama, Eiji Miyano and Yuichi Asahiro,
# found through https://www.cs.ubc.ca/~hoos/SATLIB/benchm.html

my $aim = path('t', 'aim');
for my $cnf ($aim->children(qr/cnf$/)) {
    my $solver = CaDiCaL::Solver->new;
    for ($cnf->lines_utf8) {
        next if /^[pc]/;
        next if not length;
        $solver->add($_) for split / /;
    }

    my $expected = !!($cnf =~ /yes/);
    my $got = $solver->solve;
    die "cadical returned $got" unless $got == 10 or $got == 20;
    is(($got == 10), $expected, "$cnf ok");
}

done_testing;
