use lib 't/lib';
use EvalTest;
use Test::More tests => 2;

{
    my $o = EvalTest->new;
    $o->in(1);
    is($o->out, 1);
}

TODO: {
    local $TODO = "self is broken in eval{} block";
    my $o = EvalTest->new;
    $o->in(1);
    is($o->out2, 1);
}
