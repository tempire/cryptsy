package Cryptsy;
use feature 'say';
use Mojo::Base -base;
use Mojo::UserAgent;

has ua => sub { Mojo::UserAgent->new };

sub _headers { {} }

sub all_markets {
  my $self = shift;
  my $ua   = $self->ua;
  my $cb   = shift;

  $ua->get(
    'http://pubapi.cryptsy.com/api.php?method=marketdatav2' =>
      $self->_headers() => sub {
      my ($ua, $tx) = @_;
      $tx->res->json('/success')
        ? $cb->($tx->res->json('/return/markets'))
        : $cb->();
    }
  );
}

sub market {
  my $self = shift;
  my $ua   = $self->ua;
  my $id   = shift;
  my $cb   = shift;

  $ua->get(
    Mojo::URL->new('http://pubapi.cryptsy.com/api.php')
      ->query(method => 'singlemarketdata', marketid => $id) =>
      $self->_headers() => sub {
      my ($ua, $tx) = @_;

      return $cb->() if not $tx->res->json('/success');

      my $json = $tx->res->json('/return/markets');
      $cb->($json->{shift [keys $json]});
    }
  );
}

1;
