=encoding utf8

=head1 NAME

CInet::Alien::CaDiCaL - The SAT solver CaDiCaL

=cut

# ABSTRACT: The SAT solver CaDiCaL
package CInet::Alien::CaDiCaL;
use base qw(Alien::Base);

=head1 SYNOPSIS

A statically compiled executable is available:

    use IPC::Run3;
    use CInet::Alien::CaDiCaL qw(cadical);
    
    # Run SAT solver on a DIMACS CNF file, receive a satisfiability
    # witness or undef in $witness.
    run3 [cadical, $cnf_file], \undef, \my $witness, \undef;
    
    # Clauses produced programmatically can be sent to stdin
    run3 [cadical], \&produce_clauses, \my $witness, \undef;

A dynamic library for FFI as well:

    use FFI::Platypus;
    
    my $ffi = FFI::Platypus->new;
    $ffi->lib(CInet::Alien::CaDiCaL->dynamic_libs);
    
    $ffi->attach('ccadical_signature' => [] => 'string');
    say ccadical_signature();
    # etc.

=head2 VERSION

This document describes CInet::Alien::CaDiCaL v1.0.0.

=cut

our $VERSION = "v1.0.0";

=head1 DESCRIPTION

This module builds Armin Biere's clean yet fast SAT solver C<CaDiCaL>.
Given a Boolean formula in conjunctive normal form, it checks whether
there exists an assignment to its variables which satisfies all the
clauses of the formula. If this is the case, it returns such an
assignment.

The package C<CInet::Alien::CaDiCaL> is an L<Alien::Base>. We provide
a statically linked executable, a static library and a dynamic library.
The libraries are available through standard Alien::Base methods,
for executable there is a new method:

=head2 exe

    my $program = CInet::Alien::CaDiCaL->exe;

Returns the absolute path of the C<cadical> executable bundled with
this module.

Note that the basename of this path is not guaranteed to be exactly
C<nbc_minisat_all>. It may have a custom suffix like C<_static>.

=head1 EXPORTS

There is one optional export:

=head2 cadical

    use CInet::Alien::CaDiCaL qw(cadical);
    my $program = cadical;

Returns the same path as C<exe> but is shorter to type.

=cut

use Path::Tiny;

our @EXPORT_OK = qw(cadical);
use Exporter qw(import);

sub exe {
    my $self = shift;
    path($self->dist_dir, $self->runtime_prop->{exename});
}

sub cadical {
    __PACKAGE__->exe
}

=head1 SEE ALSO

=over

=item *

The academic paper about CaDiCaL is available from Biere's
website L<http://fmv.jku.at/papers/BiereFazekasFleuryHeisinger-SAT-Competition-2020-solvers.pdf>.

=item *

The original source code for C<cadical> is on github:
L<https://github.com/arminbiere/cadical>.

=back

=head1 AUTHOR

Tobias Boege <tobs@taboege.de>

=head1 COPYRIGHT AND LICENSE

This software is copyright (C) 2020 by Tobias Boege.

This is free software; you can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

=head2 Bundled software

The C<cadical> solver is Copyright (C) 2020 by Armin Biere
who released it under the MIT license.

=cut

":wq"
