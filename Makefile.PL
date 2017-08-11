use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME => "self",
    VERSION_FROM => "lib/self.pm",
    ABSTRACT_FROM => "lib/self.pm",
    AUTHOR => 'Kang-min Liu <gugod@gugod.org>',
    PREREQ_PM => {
        'PadWalker'        => '1.93',
        'Devel::Declare'   => '0.003004',
        'B::OPCheck'       => '0.27',
        'B::Hooks::Parser' => '0.08',
        'Sub::Exporter'    => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0.42',
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url => 'git://github.com/gugod/self.git',
                web => 'https://github.com/gugod/self',
            }
        }
    },
    dist => {
        COMPRESS => "zopfli -i50",
    },
);
