use strict;
use warnings;
package EvalTest;

use self;

sub new {
    return bless {}, self;
}

sub in {
    my ($n) = args;
    self->{n} = $n;
}

sub out {
    return self->{n}
}

sub out2 {
    return eval {
        return self->{n}
    };
}

1;
