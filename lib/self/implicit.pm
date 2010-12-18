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
