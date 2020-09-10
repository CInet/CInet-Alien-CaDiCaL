use strict;
use warnings;
use autodie;
use Test::More;
use Test::Deep;

use IPC::Run3;
use Path::Tiny;
use CInet::Alien::CaDiCaL;

# This test exercises the C<assume> function to check the same base formula
# repeatedly on many different assignments. Verify the witness returned by
# the C<val> function against a database.

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
my %oriented  = map { $_ => 1 } path('t', 'oriented4-list.txt')->lines_utf8({ chomp => 1 });
my $cnf = path('t', 'oriented4.cnf');
my $solver = CaDiCaL::Solver->new;
for ($cnf->lines_utf8({ chomp => 1 })) {
    next if /^[pc]/;
    next if not length;
    $solver->add($_) for split / /;
}

# Extract the oriented gaussoid from the solver.
sub model {
    my ($solver, $len) = @_;
    my $O = '';
    for (1 .. $len) {
        my $x = $solver->val(2*$_-1) > 0;
        my $y = $solver->val(2*$_-0) > 0;
        die 'solution is inconsistent' if $x and not $y;
        $O .= '0' if $x;
        $O .= '+' if not $x and $y;
        $O .= '-' if not $x and not $y;
    }
    $O
}

sub zeros {
    my $A = shift;
    [ grep { substr($A,$_-1,1) eq '0' } 1 .. length($A) ]
}

my $count = 0;
for my $G (@gaussoids) {
    for (1 .. length($G)) {
        my $s = substr($G, $_-1, 1) eq '0' ? 1 : -1;
        $solver->assume($s * (2*$_ - 1));
    }
    if ($solver->solve == 10) {
        my $O = model($solver, length($G));
        ok $oriented{$O}, 'witness is oriented';
        cmp_deeply zeros($O), zeros($G), 'witness orients the given gaussoid';
        $count++;
    }
}

is 0+@gaussoids, 58, '58 Sn orbits of gaussoids';
is $count, 53, '53 of them orientable';

done_testing;
