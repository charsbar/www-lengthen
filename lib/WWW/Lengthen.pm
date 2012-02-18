package WWW::Lengthen;

use strict;
use warnings;
use LWP::UserAgent;

our $VERSION = '0.07';

our %KnownServices = (
  '0rz'            => qr{^http://0rz\.tw/.+},
  Metamark         => qr{^http://xrl\.us/.+},
  SnipURL          => qr{^http://snipurl\.com/.+},
  TinyURL          => qr{^http://tinyurl\.com/.+},
  snurl            => qr{^http://snurl\.com/.+},
  bitly            => qr{^http://bit\.ly/.+},
  htly             => qr{^http://ht\.ly/.+},
  isgd             => qr{^http://is\.gd/.+},
  owly             => qr{^http://ow\.ly/.+},
  urlchen          => qr{^http://urlchen\.de/.+},
  google           => qr{^http://goo\.gl/.+},
);

# Can't test, but widely used
our %PartOfOtherServices = (
  twitterco        => qr{^http://t\.co/.+},
  hatena           => qr{^http://htn\.to/.+},
  jmp              => qr{^http://j\.mp/.+},
  tumblr           => qr{^http://tmblr\.co/.+},
  facebook         => qr{^http://fb\.me/.+},
);

our %ExtraServices = (
  OneShortLink     => [ qr{^http://1sl\.net/.+}, 'OneShortLink' ],
  Shorl            => [ qr{^http://shorl\.com/.+}, 'Shorl' ],
);

# not only dead but also failed anyhow when I tested
our %UnsupportedOrDeadServices = (
  icanhaz          => qr{^http://icanhaz\.com/.+},
  urlTea           => qr{^http://urltea\.com/.+},
  BabyURL          => qr{^http://babyurl\.com/.+},
  Linkz            => qr{^http://lin\.kz/?\?.+},
  TinyClick        => qr{^http://tinyclick\.com/?\?.+},
  V3               => qr{^http://\w+\.v3\.net/},
  ShortenURL       => qr{^http://www\.shortenurl\.com/.+},
  URLjr            => qr{^http://urljr\.com/.+},
  qURL             => qr{^http://qurl\.net/.+},
  SmLnk            => qr{^http://smlnk\.com/.+},
  ShortLink        => qr{^http://shortlink\.us/.+},
  EkDk             => qr{^http://add\.redir\.ek\.dk/.+},
  MakeAShorterLink => qr{^http://tinyurl\.com/.+},
  LinkToolbot      => qr{^http://link\.toolbot\.com/.+},
  haojp            => qr{^http://hao\.jp/.+},
  Smallr           => qr{^http://smallr\.com/.+},
  unu              => qr{^http://u\.nu/.+},
  Tinylink         => [ qr{^http://tinylink\.com/.+}, 'Tinylink' ],
  durlme           => qr{^http://durl\.me/.+},
  NotLong          => qr{^http://[\w\-]+\.notlong\.com/?$},
  shadyurl         => qr{^http://5z8\.info/.+},
  miudin           => qr{^http://miud\.in/.+},
);

sub new {
  my $class = shift;

  my %services;
  if ( @_ ) {
    foreach my $name ( @_ ) {
      $services{$name} = $PartOfOtherServices{$name}
                      || $KnownServices{$name};
    }
  }
  else {
    %services = (%KnownServices, %PartOfOtherServices);
  }

  my $ua = LWP::UserAgent->new(
    env_proxy => 1,
    timeout   => 30,
    agent     => "$class/$VERSION",
    requests_redirectable => [],
  );

  bless { ua => $ua, services => \%services }, $class;
}

sub ua { shift->{ua} }

sub try {
  my ($self, $url) = @_;

  my $new_url;
  my %seen;
  my $max_try = 5;
  while ($max_try--) {
    $new_url = $self->_try($url);
    return $new_url if $new_url eq $url or $seen{$new_url}++;
    $url = $new_url;
  }
  return $url;
}

sub _try {
  my ($self, $url) = @_;

  foreach my $name ( keys %{ $self->{services} } ) {
    my $service = $self->{services}->{$name};
    next unless $service;
    if ( ref $service eq 'Regexp' ) {
      next unless $url =~ /$service/;
      my $res = $self->ua->get($url);
      next unless $res->is_redirect;
      my $location = $res->header('Location');
      return $location if defined $location;
    }
    elsif ( ref $service eq 'ARRAY' ) {
      my ($regex, $package) = @{ $service };
      next unless $url =~ /$regex/;
      $package = 'WWW::Shorten::'.$package
        unless $package =~ /^WWW::Shorten::/;
      eval "require $package";
      unless ($@) {
        my $longer_url = eval "$package\::makealongerlink('$url')";
        return $longer_url if defined $longer_url;
      }
    }
  }
  return $url;
}

sub add {
  my ($self, %hash) = @_;

  %{ $self->{services} } = ( %{ $self->{services} }, %hash );
}

1;

__END__

=head1 NAME

WWW::Lengthen - lengthen 'shortened' urls

=head1 SYNOPSIS

    use WWW::Lengthen;
    my $lenghtener = WWW::Lenghten->new;
    my $lengthened_url = $lengthener->try($url);

    # if you find some new and unsupported shortener service
    $lengthener->add( ServiceName => qr{^http://service.com/} );

    # or you may add some known extra services
    $lengthener->add( %WWW::Lengthen::ExtraServices );

=head1 DESCRIPTION

There are a bunch of URL shortening services around the world. They have slightly different APIs to shorten URLs but the lengthening part is always the same: follow the shortened URL and see the redirect.

This module tries all the known services to find a longer URL. You may say we can do it with WWW::Shorten family but you can't say which services people use to shorten URLs. You can select some specific shortening service for your website to shorten longer URLs automatically, but spammers may post URLs shortened with other shortening services to avoid offensive URLs they post to be disclosed by clever client tools that know which shortening service your site uses.

Well, this is a cat and mouse game but I hope this help you a bit, at least to save time copying and pasting to create another WWW::Shorten subclass and load it just to lengthen URLs.

=head1 METHODS

=head2 new

creates an object. Optionally you can pass an array of services to check if you want some more speed.

=head2 try

takes a (probably shortened) URL and find a longer URL. If not found, just returns the original URL.

=head2 add

takes a hash whose keys are service names and whose values are regexen to see if the tried URL should belong to the service or not. Preferably we should exclude API URLs but usually it doesn't matter as nothing would happen if we just GET them.

Several shorten services use special techniques to resolve links, such as multiple redirection or page refreshing. WWW::Lengthen doesn't support them natively at the moment, but if there's WWW::Shorten subclass, you can use it to lengthen like this:

  $self->add( Name => [ qr{^http://service.com/}, 'WWW::Shorten::ServiceName' ] );

=head2 ua

returns an LWP::UserAgent object used internally.

=head1 SUPPORTED SERVICES

=head2 Natively

=over 4

=item 0rz (http://0rz.tw/)

=item haojp (http://hao.jp/)

=item Metamark (http://xrl.us/)

=item NotLong (http://notlong.com/)

=item Smallr (http://smallr.com/)

=item SnipURL (http://snipurl.com/)

=item TinyURL (http://tinyurl.com/)

=item Snurl (http://snurl.com/)

=item bit.ly (http://bit.ly/)

=item is.gd (http://is.gd/)

=back

=head2 Require WWW::Shorten subclasses

=over 4

=item OneShortLink (http://1sl.net/)

=item Shorl (http://shorl.com/)

=item Tinylink (http://tinylink.com/)

# Tinylink may not be available now as WWW::Shorten marks this as "dead"

=back

=head2 Dead/Down/Too Heavy when I tested

not tested but probably works with WWW::Shorten subclasses.

=over 4

=item I CAN HAZ dot COM (http://icanhaz.com/) (temporarily unavailable?)

=item urlTea (http://urltea.com/) (temporarily unavailable?)

=item BabyURL (http://babyurl.com/)

=item Linkz (http://lin.kz/)

=item TinyClick (http://tinyclick.com/)

=item V3 (http://www.v3.net/)

=item ShortenURL (http://www.shortenurl.com/)

=back

=head1 SEE ALSO

L<WWW::Shorten>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
