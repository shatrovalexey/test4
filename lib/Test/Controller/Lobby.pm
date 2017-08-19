package Test::Controller::Lobby ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
use constant 'MODEL_DEFAULT' => 'Test::Model::Lobby' ;
use constant 'MODEL_USER' => 'Test::Model::User' ;
+ 1 ;

sub __user_id( $ ) {
	return +( ) unless exists( $self->{ 'data' }{ 'session_id' } ) ;

	my ( $user_id ) = $self->__object( $self->MODEL_USER )->
				user_id( $self->{ 'data' }{ 'session_id' } ) ;

	return +( ) unless defined( $user_id ) ;

	return $user_id ;
}
sub online( $ ) {
	my ( $self ) = @_ ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->online( )
	) ;
}
sub history( $ ) {
	my ( $self ) = @_ ;
	my ( $user_id ) = $self->__user_id( ) || return +( ) ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->history( $user_id )
	) ;
}
sub create( $ ) {
	my ( $self ) = @_ ;
	my ( $user_id ) = $self->__user_id( ) || return +( ) ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->create( $user_id )
	) ;
}
sub leave( $ ) {
	my ( $self ) = @_ ;
	my ( $user_id ) = $self->__user_id( ) || return +( ) ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->leave( $user_id )
	) ;
}
sub subscribe( $ ) {
	my ( $self ) = @_ ;
	my ( $user_id ) = $self->__user_id( ) || return +( ) ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->subscribe( $user_id , $self->{ 'data' }{ 'lobby_id' } )
	) ;
}
sub pass( $ ) {
	my ( $self ) = @_ ;
	my ( $user_id ) = $self->__user_id( ) || return +( ) ;
	my ( $lobby_card_id ) = $self->{ 'data' }{ 'lobby_card_id' } ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->pass( $user_id , $self->{ 'data' }{ 'lobby_card_id' } )
	) ;
}
sub suggestion( $ ) {
	my ( $self ) = @_ ;
	my ( $user_id ) = $self->__user_id( ) || return +( ) ;
	$self->__result(
		$self->__object( $self->MODEL_DEFAULT )
			->suggestion( $user_id )
	) ;
}