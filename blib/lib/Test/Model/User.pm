package Test::Model::User ;
use strict ;
use warnings ;
use parent qw(Test::Model) ;
use Digest::MD5 ;
use Data::UUID ;
use constant 'PASSWD_MIN_LEN' => 8 ;

+ 1 ;

sub new( $;% ) {
	my ( $self ) = shift( @_ )->SUPER::new(
		'md5' => Digest::MD5->new( ) ,
		'uuid' => Data::UUID->new( ) ,
		@_
	) ;
}

sub reset( $$ ) {
	my ( $self , $login , $passwd ) = @_ ;
	my $passwd_new = $self->__password( ) ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	return +( ) $dbh->do( << '.' , undef( ) , $login , $passwd ) > 0 ;
UPDATE
	`user` AS `u1`
SET
	`u1`.`passwd` := md5( ? )
WHERE
	( `u1`.`login` = ? ) AND
	( `u1`.`passwd` = md5( ? ) ) ;
.

	return $passwd_new ;
}

sub create( $$$ ) {
	my ( $self , $login , $passwd ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	return +( ) unless $dbh->do( << '.' , undef( ) , $login , $passwd ) > 0 ;
INSERT IGNORE INTO
	`user` AS `u1`
SET
	`u1`.`login` := ? ,
	`u1`.`passwd` := md5( ? ) ;
.

	my ( $user_id ) = $dbh->selectrow_array( << '.' ) || return +( ) ;
SELECT
	last_insert_id( ) AS `user_id`
.

	return $user_id ;
}

sub __uniqid( $ ) {
	my ( $self ) = @_ ;

	$self->{ 'md5' }->md5_hex( $self->{ 'uuid' }->create( )->to_string( ) ) ;
}

sub __password( $ ) {
	my ( $self ) = @_ ;
	my ( $uniqid ) = $self->__uniqid( ) ;
	my $len = $self->PASSWD_MIN_LEN + rand( ) * length( $uniqid ) ;

	substr( $uniqid , 0 , $len ) ;
}

*__session_id = * __uniqid ;

sub session_id( $$ ) {
	my ( $self , $user_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' , undef( ) , $user_id ) ;
SELECT SQL_SMALL_RESULT
	`vuo1`.`session_id`
FROM
	`v_user_online` AS `vuo1`
WHERE
	( `vuo1`.`user_id` = ? )
LIMIT 1 ;
.
}

sub __user_id_by_login_passwd( $$$ ) {
	my ( $self , $login , $passwd ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' , undef( ) , $user_id , $passwd ) ;
SELECT SQL_SMALL_RESULT
	`u1`.`id` AS `user_id`
FROM
	`user` AS `u1`
WHERE
	( `u1`.`login` = ? ) AND
	( `u1`.`passwd` = md5( ? ) )
LIMIT 1 ;
.
}

sub __user_id_by_session_id( $$ ) {
	my ( $self , $session_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' , undef( ) , $session_id ) ;
SELECT SQL_SMALL_RESULT
	`vuo1`.`user_id`
FROM
	`v_user_online` AS `vuo1`
WHERE
	( `vuo1`.`session_id` = ? )
LIMIT 1 ;
.
}

sub user_id( $$;$ ) {
	return $self->__user_id_by_login_passwd( @_ ) if @_ == 3 ;
	return $self->__user_id_by_session_id( @_ ) ;
}

sub session_update( $$ ) {
	my ( $self , $session_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	return +( ) unless $dbh->do( << '.' , undef( ) , $session_id ) > 0 ;
UPDATE
	`session` AS `s1`
SET
	`s1`.`expires` := `fs_expires`( )
WHERE
	( `s1`.`id` = ? ) ;
.

	return $session_id ;
}

sub unauth( $$ ) {
	my ( $self , $session_id ) = @_ ;

	return +( ) unless $dbh->do( << '.' , undef( ) , $session_id ) > 0 ;
UPDATE
	`session` AS `s1`
SET
	`s1`.`expires` := from_unixtime( unix_timestamp( ) -1 )
WHERE
	( `s1`.`id` = ? ) ;
.

	return $session_id ;
}

sub auth( $$$ ) {
	my ( $self , $login , $passwd ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;
	my ( $user_id ) = $self->user_id( $login , $passwd ) || return +( ) ;
	my ( $session_id ) = $self->session_id( $user_id ) ;

	return $session_id if defined( $session_id ) ;

	$session_id = $self->__session_id( ) ;

	return +( ) unless $dbh->do( << '.' , undef( ) , $user_id , $session_id ) > 0 ;
INSERT IGNORE INTO
	`session`
SET
	`user_id` := ? ,
	`session_id` := ? ;
.

	return $session_id ;
}

sub online( $ ) {
	my ( $self ) = @_ ;
	my $dbh = $self->dbh( ) || return +( ) ;

	$dbh->selectall_array( << '.' ) ;
SELECT SQL_SMALL_RESULT
	`u1`.`login`
FROM
	`v_user_online` AS `vuo1`

	INNER JOIN `user` AS `u1` ON
	( `vuo1`.`user_id` = `u1`.`id` )
GROUP BY
	1 ;
.
}