#!perl

use Test::More;

unless ($ENV{TEST_PERL_CRITIC}) {
    plan skip_all => "set TEST_PERL_CRITIC to enable this test";
}

eval { require Test::Perl::Critic };
if ($@) {
    plan skip_all => "Test::Perl::Critic required for testing PBP compliance";
}

Test::Perl::Critic::all_critic_ok();
