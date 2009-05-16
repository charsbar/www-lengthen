use strict;
use warnings;
use Test::More qw( no_plan );
use WWW::Lengthen;
use t_live::urllist;

my %tests = t_live::urllist->basic_tests;

my $l = WWW::Lengthen->new;
foreach my $name ( sort keys %tests ) {
  my ($long, $short) = @{ $tests{$name} };
  my $got = $l->try( $short ) || '';
  ok $got eq $long, "$name: $got";
  sleep 1;
}

my $tinyurl_only = WWW::Lengthen->new( 'TinyURL' );
foreach my $name ( sort keys %tests ) {
  my ($long, $short) = @{ $tests{$name} };
  my $got = $tinyurl_only->try( $short ) || '';
  if ( $name eq 'TinyURL' ) {
    ok $got eq $long, "$name: $got";
  }
  else {
    ok $got eq $short, "$name: (ignored)";
  }
  sleep 1;
}
