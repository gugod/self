use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/self.pm';

requires        'Sub::Exporter'     => '0';
build_requires  'Test::More'        => '0.42';

WriteAll;


