#!/usr/bin/env perl -w
use strict;
use Test2::V0;
plan tests => 2;

use self;

sub one {
    eval '$self';
}

no self;

sub two {
    eval '$self';
}

is( one(42), 42 );
is( two(43), undef);
