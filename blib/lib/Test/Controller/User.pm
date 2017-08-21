package Test::Controller::User ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
use constant 'DEFAULT_MODEL' => 'Test::Model::User' ;
+ 1 ;

sub online( $ ) {
	my ( $self ) = @_ ;

	$self->__result(
		$self->__object( $self->DEFAULT_MODEL )->online( )
	) ;
}
*auth = *reset = *create = sub( $ ) {
	my ( $self ) = @_ ;
	my $model = $self->__object( $self->DEFAULT_MODEL ) ;
	my $sub = $self->__sub( ) ;

	$self->__result(
		$model->$sub( @{ $self->{ 'data' } }{ + qw(login passwd) } )
	) ;
} ;
sub unauth( $ ) {
	my ( $self ) = @_ ;

	$self->__result(
		$self->__object( $self->DEFAULT_MODEL )->unauth( $self->{ 'data' }{ 'session_id' } )
	) ;
}
sub session_update( $ ) {
	my ( $self ) = @_ ;

	$self->__result(
		$self->__object( $self->DEFAULT_MODEL )->session_update( $self->{ 'data' }{ 'session_id' } )
	) ;
}