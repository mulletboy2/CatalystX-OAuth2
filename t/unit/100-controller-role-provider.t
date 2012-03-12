use strictures 1;
use Test::More;
use Test::Exception;
use Plack::Test;
use HTTP::Request::Common;

use lib 't/lib';
use MyApp;

my $mock = mock_context('MyApp');

my $c = $mock->(GET '/request');

$c->dispatch;

is_deeply $c->error, [], 'survives oauth2 dispatch';
lives_ok { $c->req->oauth2 } 'installs oauth2 role on requests';

sub mock_context {
  my($class) = @_;
  sub {
    my($req) = @_;
    my $c;
    test_psgi app => sub {
      my $env = shift;
      $c = $class->prepare(env => $env, response_cb => sub {});
      return [200, ['Content-type' => 'text/plain'], ['Created mock OK']]
      },
      client => sub {
        my $cb = shift;
        $cb->($req);
    };
    return $c;
  }
}

done_testing();