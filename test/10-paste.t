use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use lib 'test';

my $t;
my ($id1, $id2, $id3);

subtest q{main} => sub {
  ok $t = Test::Mojo->new('ExampleApp'), 'instantiate';

  $t->get_ok('/paste')->status_is(200)
      ->content_like(qr/Your text here/, 'correct page');
};

subtest q{create} => sub {
  $t->post_ok('/paste' => form => {pastie => 'XyZ'})
      ->status_is(200, 'successful post')
      ->content_like(qr{/paste/}, 'got id')
      ->content_unlike(qr/\bscript\b/, 'no js');
  ok $id1 = $t->tx->res->text, 'got result';

  $t->post_ok('/paste' => form => {pastie => "Abc\nABC\n"})
      ->status_is(200, 'successful post')
      ->content_like(qr{/paste/}, 'got id')
      ->content_unlike(qr/\bscript\b/, 'no js');
  ok $id2 = $t->tx->res->text, 'got paste id';

  isnt $id1, $id2, 'Distinct paste ids';

  $t->post_ok('/paste' => form => {pastie => '  '})
      ->status_is(400)
      ->content_like(qr/missing content/, 'correctly rejected');

  $t->post_ok('/paste' => form => {pastie => 'meh', destination => 'show'})
      ->status_is(302)
      ->tap(sub { $id3 = shift->tx->res->text })
      ->header_like(Location => qr{$id3}, 'correct redirect');
};

subtest q{show} => sub {
  $t->get_ok('/paste/dummy')->status_is(410)
      ->content_like(qr/has gone/, 'correct message');

  $t->get_ok($id1)->status_is(200)
      ->content_like(qr/XyZ/, 'retrieved first paste')
      ->content_unlike(qr/\bscript\b/, 'got raw version');
  $t->get_ok($id2)->status_is(200)
      ->content_like(qr/ABC/, 'retrieved second paste')
      ->content_unlike(qr/\bscript\b/, 'got raw version');

  $t->get_ok($id1 .'?lang=1')->status_is(200)
      ->content_like(qr/XyZ/, 'retrieved first paste')
      ->content_like(qr/\bscript\b/, 'got pretty version');
  $t->get_ok($id2 .'?lang=1')->status_is(200)
      ->content_like(qr/ABC/, 'retrieved second paste')
      ->content_like(qr/\bscript\b/, 'got pretty version');
};

subtest q{edit} => sub {
  ok 'TODO';
};

done_testing();
