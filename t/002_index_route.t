use strict;
use warnings;

use Test::App;
use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;

my $app = Test::App->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/' );

ok( $res->is_success, '[GET /] successful' );
