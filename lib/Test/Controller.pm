package Test::Controller ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
+ 1 ;

sub dispatch( $$;@ ) {
	my ( $self , $data ) = splice( @_ , 0 , 2 ) ;
	my $action = $self->{ 'creator' }->action( ) || return +( ) ;
	my $actions = $self->{ 'dancer' }{ 'config' }{ 'actions' } ;

	return +( ) unless exists( $actions->{ $action } ) ;

	my ( $package , $method ) = $self->__split_package( $actions->{ $action } ) ;
	my $result = eval { $self->__object( $package , 'data' => $data , @_ )->$method( $self ) } ;

	warn( $@ ) and return +( ) if $@ ;

	+ $result ;
}