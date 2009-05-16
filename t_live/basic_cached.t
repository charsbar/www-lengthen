use strict;
use warnings;
use Test::More qw( no_plan );
use WWW::Lengthen::Cached;
use Cache::Memcached;
use t_live::urllist;

my %tests = t_live::urllist->basic_tests;

my $l = WWW::Lengthen::Cached->new;
$l->setup_cached( Cache::Memcached->new );
foreach my $name ( sort keys %tests ) {
  my ($long, $short) = @{ $tests{$name} };
  my $got = $l->try( $short ) || '';
  ok $got eq $long, "$name: $got";
  sleep 1;
}

foreach my $name ( sort keys %tests ) {
  my ($long, $short) = @{ $tests{$name} };
  my $got = $l->try( $short ) || '';
  ok $got eq $long, "$name: $got";
  sleep 1;
}
