use lib 't/lib';
use EvalTest;
use Test::More tests => 3;

{
    my $o = EvalTest->new;
    $o->in(1);
    is($o->out, 1);
}

{
    my $o = EvalTest->new;
    $o->in(1);
    is($o->out2, 1);
}

{
    my $o = EvalTest->new;
    $o->in(1);
    is($o->out3, 1);
}
