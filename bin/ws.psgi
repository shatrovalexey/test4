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
	// print( &Dumper( @_ ) ) ;
} ;
get '/new_listener' => sub {
	my $self = shift( @_ ) ;

	$self->request->env->{ 'hippie.listener' }->subscribe( $app->channel( ) ) ;
};
get '/message' => sub {
	my ( $self ) = @_ ;
	my $result = $app->dispatch( $self ) ;

	$app->publish( $result ) ;
};

$app->build( ) ;