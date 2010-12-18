#!/usr/bin/env perl
use strict;
use warnings;

package Joey;
use self::implicit;

sub new {
    my ($class, $number) = @_;
    return bless { n => $number }, $class;
}

sub single() {
    $self->{n};
}

sub double() {
    single + single
}

sub add {
    my ($x) = @args;
    single + $x;
}

package main;
use Test::More tests => 3;

my $x = Joey->new(10);

is $x->single,  10;
is $x->double,  20;
is $x->add(15), 25;
