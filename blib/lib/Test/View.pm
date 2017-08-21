package Test::View ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
+ 1 ;

sub render( $;@ ) {
	my $self = shift( @_ ) ;

	$self->__publish( $self->__render( $_ ) ) foreach @_ ;
}
sub parse( $$ ) { $_[ 0 ]{ 'creator' }->json_decode( $_[ 1 ] ) }
sub __render( $$ ) { $_[ 0 ]{ 'creator' }->json_encode( $_[ 1 ] ) }
sub __publish( $$ ) { $_[ 0 ]{ 'creator' }->channel( )->publish( $_[ 1 ] ) }