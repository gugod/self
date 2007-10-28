
use lib 't/lib';
use Counter;
use Test::More tests => 3;

my $o = Counter->new;

is($o->out, 0);

$o->inc;

is($o->out, 1);

$o->set(5);

is($o->out, 5);
