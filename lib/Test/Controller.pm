package Test::Controller ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
+ 1 ;

sub dispatch( $$;@ ) {
	my ( $self , $data ) = @_ ;
	my $action = $self->{ 'creator' }->action( ) || return +( ) ;
	my $actions = $self->{ 'dancer' }{ 'config' }{ 'actions' } ;

	return +( ) unless exists( $actions->{ $action } ) ;

	my ( $package , $method ) = $self->__split_package( $actions->{ $action } ) ;
	my $result = eval { $self->__object( $package , 'data' => $data )->$method( $self , @_ ) } ;

	warn( $@ ) and return +( ) if $@ ;

	+ $result ;
}

sub __object( $$;@ ) {
	my ( $self , $package , @args ) = @_ ;
	$self->__coalesce( ( $self->{ '__object' } ||= { } ) , $package , sub {
		require( $package ) ;
		$package->import( ) ;
		$package->new( 'creator' => $self , @args ) ;
	} ) ;
}