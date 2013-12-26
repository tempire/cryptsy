use Cryptsy;
use Test::Most;
use Mojo::Util 'monkey_patch';
use Data::Dumper;

monkey_patch Cryptsy => _headers => sub {
  {qw/ connection close /}
};

ok my $c = Cryptsy->new;
my $market_id;

Mojo::IOLoop->delay->steps(
  sub {
    my $delay = shift;

    $c->all_markets(
      sub {
        my $json = shift;
        my $market = shift [keys $json];

        is ref $json->{$market} => 'HASH',
          "$market, ($json->{$market}->{primaryname})";

        $market_id = $json->{$market}->{marketid};

        $delay->begin(0)->();
      }
    );

  },
  sub {

    $c->market(
      $market_id => sub {
        my $json = shift;

        is $json->{marketid} => $market_id;
      }
    );
  }
);

Mojo::IOLoop->start;

done_testing;
