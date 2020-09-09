use strict;
use warnings;
use autodie;
use Test::More;

use IPC::Run3;
use Path::Tiny;
use CInet::Alien::CaDiCaL;

# This test exercises the C<assume> function to check the same base formula
# repeatedly on many different assignment.

# TODO: Assert the C<val> function as well, for example by including a list
# of all oriented 4-gaussoids and checking the witness against that.

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
    $ffi->attach('assume' => ['solver_t', 'int'] => 'void');
    $ffi->attach('val' => ['solver_t', 'int'] => 'int');
}

# These files are adapted from https://gaussoids.de. The original encoding
# of the formula for oriented gaussoids on n=4 does not allow projection to
# orientable gaussoids. The encoding has been changed to
#
#   a_{ij|K} = 0  <==> V_{ij|K} = 1 and V_{ij|K}' = 1
#   a_{ij|K} = +  <==> V_{ij|K} = 0 and V_{ij|K}' = 1
#   a_{ij|K} = -  <==> V_{ij|K} = 0 and V_{ij|K}' = 0
#
# which allows testing for orientability of any given gaussoids by
# projecting to V_{ij|K}. The numbering of the variables is the same.
my @gaussoids = path('t', 'gaussoids4-mod-Sn.txt')->lines_utf8({ chomp => 1 });
my $cnf = path('t', 'oriented4.cnf');
my $solver = CaDiCaL::Solver->new;
for ($cnf->lines_utf8) {
    next if /^[pc]/;
    next if not length;
    $solver->add($_) for split / /;
}

my $count = 0;
for my $G (@gaussoids) {
    for (1 .. length($G)) {
        my $s = substr($G, $_-1, 1) eq '0' ? 1 : -1;
        $solver->assume($s * (2*$_ - 1));
    }
    $count++ if $solver->solve == 10;
}

is 0+@gaussoids, 58, '58 Sn orbits of gaussoids';
is $count, 53, '53 of them orientable';

done_testing;
