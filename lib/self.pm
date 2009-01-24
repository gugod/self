use strict;
use warnings;

package self;
use 5.006;

our $VERSION = '0.30';
use Sub::Exporter;

use B::Hooks::Parser;

sub import {
    my ($class) = @_;

    B::Hooks::Parser::inject('use B::OPCheck const => check => \&self::_check;');

    my $exporter = Sub::Exporter::build_exporter({
        into_level => 1,
        exports => [qw(self args)],
        groups  => { default =>  [ -all ] }
    });
    $exporter->(@_);
}

sub _check {
    my $linestr = B::Hooks::Parser::get_linestr;
    my $offset  = B::Hooks::Parser::get_linestr_offset;

    if (substr($linestr, $offset, 3) eq 'sub') {
        my $line = substr($linestr, $offset);
         if ($line =~ m/^sub\s.*{ /x ) {
            if (index($line, '{my($self,@args)=@_;') < 0) {
                substr($line, index($line, '{') + 1, 0)  = 'my($self,@args)=@_;';
                B::Hooks::Parser::inject($line);
            }
        }
    }
}

sub _args {
    my $level = 2;
    my @c = ();
    package DB;
    @c = caller($level++)
        while !defined($c[3]) || $c[3] eq '(eval)';
    return @DB::args;
}

sub self {
    (_args)[0];
}

sub args {
    my @a = _args;
    return @a[1..$#a];
}

1;

__END__

=head1 NAME

self - provides '$self' in OO code.

=head1 VERSION

This document describes self version 0.30.

=head1 SYNOPSIS

    package MyModule;
    use self;

    # Write constructor as usual
    sub new {
        return bless({}, shift);
    }

    # '$self' is special now.
    sub foo {
        $self->{foo}
    }

    # '@args' too
    sub set {
        my ($foo, $bar) = @args;
        $self->{foo} = $foo;
        $self->{bar} = $bar;
    }

=head1 DESCRIPTION

This module adds C<$self> and C<@args> variables in your code. So you
don't need to say:

    my $self = shift;

The provided C<$self> and C<@args> are lexicals in your sub, and it's
always the same as saying:

    my ($self, @args) = @_;

... in the first line of sub.

However it is not source filtering, but compile-time code
injection. For more info about code injection, see L<B::Hooks::Parser>
or L<Devel::Declare>.

It also exports a C<self> and a C<args> functions. Basically C<self> is just
equal to C<$_[0]>, and C<args> is just C<$_[1..$#_]>.

For convienence (and for backward compatibility), these two functions
are exported by default. If you don't want them to be exported, you
need to say:

    use self ();

It is recommended to use variables instead, because it's much much
faster. There's a benchmark program under "example" directory compare
them: Here's one example run:

    > perl -Ilib examples/benchmark.pl
              Rate  self $self
    self   46598/s    --  -92%
    $self 568182/s 1119%    --

=head1 INTERFACE

=over

=item $self, or self

Return the current object.

=item @args, or args

Return the argument list.

=back

=head1 CONFIGURATION AND ENVIRONMENT

self.pm requires no configuration files or environment variables.

=head1 DEPENDENCIES

C<B::OPCheck>, C<B::Hooks::Parser>, C<Sub::Exporter>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-self@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, 2008, 2009, Kang-min Liu C<< <gugod@gugod.org> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
