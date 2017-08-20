package Test::DBA ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;
+ 1 ;

sub __connection( $ ) {
	my ( $self ) = @_ ;

	return $self->{ 'dbh' } if exists( $self->{ 'dbh' } ) ;

	my $config = $_[ 0 ]{ 'dancer' }{ 'config' }{ 'db' } ;

	$config->{ 'dsn' } = sprintf( @$config{ + qw(dsn_pattern database host port) } )
							unless exists( $config->{ 'dsn' } ) ;

	$self->{ 'dbh' } = DBI->connect_cached( @$config{ + qw(dsn login passwd attrs) } ) ;

	until ( undef( ) ) {
		last( ) if exists( $self->{ 'dbh' } ) &&
				&UNIVERSAL::can( $self->{ 'dbh' } , 'ping' ) &&
				( $self->{ 'dbh' }->ping( ) > 0 ) ;

		$self->{ 'dbh' } = DBI->connect( @$config{ + qw(dsn login passwd attrs) } ) ;
	} ;

	return $self->{ 'dbh' } ;
}

sub __prepare( $$ ) { $_[ 0 ]->__connection( )->prepare_cached( $_[ 1 ] ) }
sub __prepare_execute( $$;@ ) {
	my ( $self , $sql ) = splice( @_ , 0 , 2 ) ;
	my $sth = $self->__prepare( $sql ) ;
	$sth->execute( @_ ) ;
	+ $sth ;
}

*selectrow_array = *selectrow_hashref = *selectall_array = *selectall_hashref = *do = sub ( $$;@ ) {
	my ( $self , $sql ) = splice( @_ , 0 , 2 ) ;
	my $sub = 'fetch' . ( $self->__sub( ) =~ m{^select((?:row|all)_.+)$}os )[ 0 ] ;
	my $sth = $self->__prepare_execute( $sql ) ;
	my @result = $sth->$sub( @_ ) ;
	$sth->finish( ) ;

	return @result ;
}