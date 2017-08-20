use strict;
use warnings;
use Dancer2;
use FindBin;
use Data::Dumper ;
use lib "$FindBin::Bin/../lib";

use Test::WS ;

my $app = Test::WS->new( ) ;

get '/' => sub {
	&template( 'index' ) ;
	# print( &Dumper( @_ ) ) ;
} ;
get '/new_listener' => sub {
	$app->subscribe( @_ ) ;
};
get '/message' => sub {
	my $result = $app->dispatch( @_ ) ;

	$app->publish( $result ) ;
};

$app->build( ) ;