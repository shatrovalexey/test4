package Test::MVC ;
use strict ;
use warnings ;
use parent +qw(Test::Base) ;
use Test::Controller ;
use Test::Model ;
use Test::View ;
use constant 'PACKAGE_SEPARATOR' => '::' ;
+ 1 ;

sub new( $;% ) {
	my $class = shift( @_ ) ;
	my ( $parent_package , $class_name ) = $class->__split_package( ) ;

	$class->SUPER::new( 'parent_package' => $parent_package , 'class_name' => $class_name , @_ ) ;
}

sub __component( $$;% ) {
	my ( $self , $type , %args ) = @_ ;
	my $class_name = ucfirst( $type ) ;
	my $package_name = $self->{ 'parent_package' } ;
	my $package = $self->__join_package( $package_name , $class_name ) ;

	$self->__coalesce( lc( $type ) => sub { $self->__object( $package , %args ) } ) ;
}

sub __split_package( $;$ ) { $_[ -1 ] =~ m{(.*)\Q${\$_[ 0 ]->PACKAGE_SEPARATOR}\E([^=]*?)}os }
sub __join_package( $$;$ ) {
	my $self = shift( @_ ) ;

	unshift( @_ , ref( $self ) ) unless @_ > 1 ;

	join( $self->PACKAGE_SEPARATOR , @_ ) ;
}

*__controller = *__model = *__view = sub( $;% ) {
	my $self = shift( @_ ) ;
	my ( undef( ) , $type ) = $self->__split_package( $self->__sub( ) ) ;

	return +( ) unless $type =~ m{^_*}os ;

	$self->__component( $' , @_ ) ;
} ;

sub __object( $$;@ ) {
	my ( $self , $package ) = splice( @_ , 0 , 2 ) ;
	$self->__coalesce( ( $self->{ 'object' } ||= { } ) , $package , sub {
		require( $package ) ;

		$package->import( ) ;
		$package->new( 'creator' => $self , @_ ) ;
	} ) ;
}

sub __sub( $;$ ) {
	my ( $self , $level ) = @_ ;
	$level = 1 unless defined( $level ) ;
	my $sub_ref = ( caller( $level ) )[ 3 ] ;
	my $sub = ( $self->__split_package( $sub_ref ) )[ 1 ] ;
}

sub __result( $;@ ) { + { +shift( @_ )->__sub( 2 ) => \@_ } }