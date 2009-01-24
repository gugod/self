use strict;

package Selfvar;
use self;

sub new { bless {}, shift }

sub pet {
    if ($args[0]) {
        $self->{pet} = $args[0];
    }

    return $self->{pet};
}


1;
