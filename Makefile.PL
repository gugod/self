use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/self.pm';

requires
    'Devel::Declare' => '003004',
    'B::OPCheck' => '0.27',
    'B::Hooks::Parser' => '0.08',
    'Sub::Exporter'     => '0';

build_requires  'Test::More'        => '0.42';

tests 't/*.t';
author_tests 'xt';

WriteAll;


