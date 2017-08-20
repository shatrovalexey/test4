package Test::Model ;
use strict ;
use warnings ;
use parent qw(Test::MVC) ;

+ 1 ;

sub __dbh( $ ) { $_[ 0 ]{ 'creator' }{ 'creator' }->dbh( ) }
sub __last_insert_id( $ ) {
	my $dbh = $_[ 0 ]->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' ) ;
SELECT
	last_insert_id( ) AS `id` ;
.
}
sub __found_rows( $ ) {
	my $dbh = $_[ 0 ]->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' ) ;
SELECT
	found_rows( ) AS `count` ;
.
}