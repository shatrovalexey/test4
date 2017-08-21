package Test::Base ;
use strict ;
use warnings ;
+ 1 ;

sub new( $;@ ) {
	my ( $class ) = shift( @_ ) ;
	bless( { @_ } , $class ) ;
}

sub __coalesce( $$$;$@ ) {
	my $self = shift( @_ ) ;

	unshift( @_ , $self ) unless ref( $_[ 0 ] ) ;

	my ( $var , $key ) = splice( @_ , 0 , 2 ) ;

	return $var->{ $key } if exists( $var->{ $key } ) ;

	my $result = eval { shift( @_ )->( $self , @_ ) } ;

	warn( $@ ) and return +( ) if $@ ;

	$var->{ $key } = $result ;
}