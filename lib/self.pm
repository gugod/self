use strict;
use warnings;

package self;
use base 'Exporter::Lite';
use v5.8.0;

our @EXPORT = qw(self args);

sub db_args {
    my @c = do {
        package DB;
        @DB::args = ();
        caller(2);
    };
    return @DB::args;
}

sub self {
    (db_args)[0];
}

sub args {
    my @a = db_args;
    return @a[1..$#a];
}

1;

__END__
