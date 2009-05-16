package #  hide from PAUSE
  t_live::urllist;

use strict;
use warnings;
use WWW::Lengthen;

my $ex    = 'http://example.com/';
my $ex_t  = 'http://example.com/test';
my %tests = (
  '0rz'        => [ $ex_t => 'http://0rz.tw/443v7' ],
  Metamark     => [ $ex   => 'http://xrl.us/bdgj9' ],
  NotLong      => [ $ex   => 'http://exampletest.notlong.com' ],
  Smallr       => [ $ex   => 'http://smallr.com/2ne' ],
  SnipURL      => [ $ex   => 'http://snipurl.com/1vv5c' ],
  TinyURL      => [ $ex   => 'http://tinyurl.com/kotu' ],
  urlTea       => [ $ex   => 'http://urltea.com/1y' ],
  haojp        => [ $ex   => 'http://hao.jp/hb' ],
  snurl        => [ $ex   => 'http://snurl.com/fuz4q' ],
  icanhaz      => [ $ex   => 'http://icanhaz.com/example' ],
  OneShortLink => [ $ex   => 'http://1sl.net/1239' ],
  Tinylink     => [ $ex_t => 'http://tinylink.com/?nlxzHox18M' ],
  Shorl        => [ $ex   => 'http://shorl.com/fylevihehyra' ],
  ShortenURL   => [ $ex_t => 'http://www.shortenurl.com/9ugbj' ],
  bitly        => [ $ex   => 'http://bit.ly/VDcn' ],
  isgd         => [ $ex   => 'http://is.gd/1NTB' ],
);

sub basic_tests {
  return map { $_ => $tests{$_} } keys %WWW::Lengthen::KnownServices;
}

sub extra_tests {
  return map { $_ => $tests{$_} } keys %WWW::Lengthen::ExtraServices;
}

1;
