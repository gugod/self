use strict;
use warnings;

package self;
use 5.006;

our $VERSION = '0.15';
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
    if ($linestr =~ m/^ sub \s+ \w+ \s+ { /x ) {
        if (index($linestr, '{my($self,@args)=@_;') < 0) {
            $linestr =~ s/{/{my(\$self,\@args)=\@_;/;
            B::Hooks::Parser::set_linestr($linestr);
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

self - Provides "self" and "args" keywords in your OO program.

=head1 VERSION

This document describes self version 0.15

=head1 SYNOPSIS

    package MyModule;
    use self;

    # Write constructor as usual
    sub new {
        return bless({}, shift);
    }

    # 'self' is special now.
    sub foo {
        self->{foo}
    }

    # 'args' too
    sub set {
        my ($foo, $bar) = args;
        self->{foo} = $foo;
        self->{bar} = $bar;
    }

=head1 DESCRIPTION

This module adds C<self> and C<args> keywords in your package. It's really just
handy helpers to get rid of:

    my $self = shift;

Basically, C<self> is just equal to C<$_[0]>, and C<args> is just C<$_[1..$#_]>.

Noted that they are not scalar variables, but barewords.

The "examples" directory in the distribution file contains a simple
Counter object example written with "self".

=head1 INTERFACE

=over

=item self

Return the current object.

=item args

Return the argument list.

=back

=head1 CONFIGURATION AND ENVIRONMENT

self.pm requires no configuration files or environment variables.

=head1 DEPENDENCIES

C<Sub::Exporter>

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

Copyright (c) 2007, Kang-min Liu C<< <gugod@gugod.org> >>.

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
