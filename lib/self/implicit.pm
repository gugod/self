package self::implicit;
use 5.006;
use strict;
use warnings;

use Devel::Declare ();
use B::Hooks::Parser;
use PadWalker qw(peek_my);

our $VERSION = '0.32';

my $NO_SELF;

sub import {
    my ($class) = @_;
    my $caller = caller;

    B::Hooks::Parser::setup();

    my $linestr = B::Hooks::Parser::get_linestr();
    my $offset  = B::Hooks::Parser::get_linestr_offset();
    substr($linestr, $offset, 0) = 'use PadWalker ();use B::OPCheck const => check => \&self::implicit::_check;';
    B::Hooks::Parser::set_linestr($linestr);
}

# This routine is almost the same as self::_check, the only difference is the injected $code.
sub _check {
    my $op = shift;
    my $caller = caller;
    return if $NO_SELF;
    return unless ref($op->gv) eq 'B::PV';

    my $linestr = B::Hooks::Parser::get_linestr;
    my $offset  = B::Hooks::Parser::get_linestr_offset;

    my $code = q{if(ref($_[0]) ne __PACKAGE__){my $x = PadWalker::peek_my(1)->{'$self'};unshift @_,$$x if $x;};my($self,@args)=@_;};

    if (substr($linestr, $offset, 3) eq 'sub') {
        my $line = substr($linestr, $offset);
         if ($line =~ m/^sub\s.*{ /x ) {
            if (index($line, "{$code") < 0) {
                substr($linestr, $offset + index($line, '{') + 1, 0) = $code;
                B::Hooks::Parser::set_linestr($linestr);
            }
        }
    }

    # This elsif block handles:
    # sub foo
    # {
    # ...
    # }
    elsif (index($linestr, 'sub') >= 0) {
        $offset += Devel::Declare::toke_skipspace($offset);
        if ($linestr =~ /(sub.*?\n\s*{)/) {
            my $pos = index($linestr, $1);
            if ($pos + length($1) - 1 == $offset) {
                substr($linestr, $offset + 1, 0) = $code;
                B::Hooks::Parser::set_linestr($linestr);
            }
        }
    }

}

sub unimport {
    my ($class) = @_;
    my $caller = caller;
    $NO_SELF = 1;
}

1;

__END__

=head1 NAME

self::implicit - provides '$self' in OO code, in an implicit way.

=head1 SYNOPSIS

    package MathGuy;
    use self::implicit;

    # Write a normal constructor
    sub new {
        my ($class, $number) = @_;
        return bless({ number => $number }, $class);
    }

    # $self is now a special variable
    sub single() { $self->{number} }

    # It does not have to be said for method invacation
    sub double() { single * 2      }

    # '@args' too
    sub add {
        my ($n) = @args;
        return single + $n;
    }

    package main;
    my $tom = MathGuy->new(10);

    print $tom->double; #=> 20
    print $tom->add(3); #=> 13

=head1 DESCRIPTION

This module adds C<$self> and C<@args> variables in your code like
C<self.pm>, and it also eliminate the need to say '$self->' in your
code.  Normal function invocation will become method invocation, if
there is a C<$self> variable in the caller context.

=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>

=head1 LICENCE AND COPYRIGHT

See C<self.pm>

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
