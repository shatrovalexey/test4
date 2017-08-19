package Test::WS ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
use Dancer2 ;
use AnyMQ ;
use Plack::Builder;
+ 1 ;

sub build( $ ) {
	my ( $self ) = @_ ;

	builder {
		mount '/' => dance ;
		mount '/_hippie' => builder {
			enable '+Web::Hippie' ;
			enable '+Web::Hippie::Pipe' , 'bus' => $self->bus( ) ;
			dance ;
		} ;
	} ;
}

sub publish( $;@ ) { shift( @_ )->__view( )->render( @_ ) }

sub dispatch( $$ ) {
	my ( $self , $dancer ) = @_ ;

	$self->{ 'dancer' } = $dancer ;
	$self->__controller( )->dispatch( 'data' => $self->data( ) ) ;
}

sub data( $ ) {
	my ( $self ) = @_ ;

	$self->__coalesce( 'data' => sub {
		my $message = $self->{ 'dancer' }->request->env->{ 'hippie.message' } ;
		my $result = eval { $self->__view( )->parse( $message ) } ;

		warn( $@ ) and return +( ) if $@ ;

		return $result ;
	} ) ;
}

sub bus( $ ) { $_[ 0 ]->__coalesce( 'bus' => sub { AnyMQ->new( ) } ) }

sub channel( $ ) {
	my ( $self ) = @_ ;

	$self->__coalesce( 'channel' => sub { $self->bus( )->topic( 'channel' ) } ) ;
}

sub action( $ ) {
	my ( $self ) = @_ ;

	$self->__coalesce( 'action' => sub {
		my $data = $self->data( ) || return +( ) ;

		$data->{ 'action' } ;
	} ) ;
}