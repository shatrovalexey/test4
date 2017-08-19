package Test::Model::Lobby ;
use strict ;
use warnings ;
use parent qw(Test::Model) ;
use constant 'LOBBY_STATE_PLAYING' => 2 ;
use constant 'LOBBY_STATE_PASS' => 4 ;
use constant 'LOBBY_STATE_ORPHANED' => 5 ;

+ 1 ;

sub __is_online( $$$ ) {
	my ( $self , $lobby_id , $user_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' , undef( ) , $lobby_id , $user_id ) ;
SELECT
	`l1`.`id` AS `lobby_id`
FROM
	`lobby` AS `l1`
WHERE
	( `l1`.`id` = ? ) AND
	( ? IN ( `l1`.`user_id_creator` , `l1`.`user_id_competitor` ) ) AND
	( `l1`.`done` IS null )
LIMIT 1 ;
.
}

sub __last_user_pass( $$ ) {
	my ( $self , $lobby_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	my $result = $dbh->selectrow_hashref( << '.' , undef( ) , $lobby_id , $self->LOBBY_STATE_PASS ) ;
SELECT SQL_CALC_FOUND_ROWS SQL_SMALL_RESULT
	`lh1`.* ,
	`fs_expired`( `lh1`.`created` ) AS `expired`
FROM
	`lobby_history` AS `lh1`
WHERE
	( `lh1`.`lobby_id` = ? ) AND
	( `lh1`.`lobby_state_id` = ? )
ORDER BY
	`lh1`.`id` DESC
LIMIT 1 ;
.
	return +( ) unless ref( $result ) ;

	$result->{ 'count' } = $self->__found_rows( ) ;

	return $result ;
}

sub __last_user_pass_same_user( $$$\% ) {
	my ( $self , $lobby_id , $user_id , $last_user_pass ) = @_ ;

	$last_user_pass = $self->__last_user_pass( $lobby_id ) || return +( ) ;

	return + ( ) unless $last_user_pass->{ 'user_id' } == $user_id ;
	return $last_user_pass ;
}

sub card( $$ ) {
	my ( $self , $lobby_card_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectrow_hashref( << '.' , undef( ) , $lobby_card_id ) ;
SELECT SQL_SMALL_RESULT SQL_CACHE
	`lc1`.*
FROM
	`lobby_card` AS `lc1`
WHERE
	( `lc1`.`id` = ? )
LIMIT 1 ;
.
}

sub history( $$ ) {
	my ( $self , $user_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectall_hashref( << '.' , undef( ) , $user_id ) ;
SELECT SQL_SMALL_RESULT
	`ls1`.`title` AS `lobby_state_title` ,
	`u1`.`login` AS `user_login` ,
	`lh1`.`created` AS `lobby_history_created`
FROM
	`lobby` AS `l1`

	INNER JOIN `lobby_history` AS `lh1` ON
	( `l1`.`id` = `lh1`.`lobby_id` )

	INNER JOIN `lobby_state` AS `ls1` ON
	( `lh1`.`lobby_state_id` = `ls1`.`id` )

	INNER JOIN `user` AS `u1` ON
	( `lh1`.`user_id` = `u1`.`id` )
WHERE
	( ? IN ( `l1`.`user_id_creator` , `l1`.`user_id_competitor` ) ) AND
	( `l1`.`done` IS null )
ORDER BY
	`lh1`.`created` DESC ;
.
}

sub online( $ ) {
	my ( $self ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	my @lobbyes = $dbh->selectall_hashref( << '.' ) || return +( ) ;
SELECT
	`l1`.*
FROM
	`lobby` AS `l1`
WHERE
	( `l1`.`won` < ? ) ;
.

	foreach my $lobby ( @lobbyes ) {
		@$lobby{ + qw(lobby_state_title user_login lobby_history_created) } =
			$dbh->selectrow_array( << '.' , undef( ) , $lobby_id ) ;
SELECT SQL_SMALL_RESULT
	`ls1`.`title` AS `lobby_state_title` ,
	`u1`.`login` AS `user_login` ,
	`lh1`.`created` AS `lobby_history_created`
FROM
	`lobby_history` AS `lh1`

	INNER JOIN `lobby_state` AS `ls1` ON
	( `lh1`.`lobby_state_id` = `ls1`.`id` )

	INNER JOIN `user` AS `u1` ON
	( `lh1`.`user_id` = `u1`.`id` )
WHERE
	( `lh1`.`lobby_id` = ? )
ORDER BY
	`lh1`.`created` DESC
LIMIT 1 ;
.
	}

	return @lobbyes ;
}

sub suggestion( $$ ) {
	my ( $self , $user_id ) = @_ ;
	my ( $lobby_id ) = $self->__user_lobby_id( $user_id ) || return +( ) ;
	my %last_user_pass ;

	return +( ) if $self->__last_user_pass_same_user( $user_id , \%last_user_pass ) ;

	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectall_hashref( << '.' , @last_user_pass{ +qw(lobby_card_id lobby_card_id) } ) ;
SELECT
	`t1`.*
FROM
	(
		SELECT
			`lc1`.*
		FROM
			`lobby_card` AS `lc1`
		WHERE
			( `lc1`.`id` = ? )
		UNION DISTINCT
		SELECT
			`lc1`.*
		FROM
			`lobby_card` AS `lc1`
		WHERE
			( `lc1`.`id` <> ? )
		ORDER BY
			`lc1`.`id` = ? DESC ,
			rand( ) ASC
		LIMIT 2
	) AS `t1`
ORDER BY
	rand( ) ASC ;
.
}

sub __user_lobby_id( $$ ) {
	my ( $self , $user_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	$dbh->selectrow_array( << '.' , undef( ) , $user_id ) ;
SELECT
	`l1`.`id` AS `lobby_id`
FROM
	`lobby` AS `l1`
WHERE
	( ? IN ( `l1`.`user_id_creator` , `l1`.`user_id_competitor` ) ) AND
	( `l1`.`done` IS null ) ;
.
}

sub expired( $$ ) {
	my ( $lobby_id ) = $self->__user_lobby_id( $user_id ) || +( ) ;
	my ( $last_user_pass ) = $self->__last_user_pass( $lobby_id ) ;
}

sub pass( $$$ ) {
	my ( $self , $user_id , $lobby_card_id ) = @_ ;
	my ( $lobby_id ) = $self->__user_lobby_id( $user_id ) || +( ) ;

	if ( my ( $last_user_pass ) = $self->__last_user_pass( $lobby_id ) ) {
		if ( $last_user_pass->{ 'expired' } < 1 ) {
			return +( ) if $last_user_pass->{ 'user_id' } == $user_id ;
		} else {
			my $dbh = $self->__dbh( ) || return +( ) ;
			my $user_id_competitor = $dbh->selectrow_array( << '.' , undef( ) , $user_id ) ;
SELECT SQL_CACHE SQL_SMALL_RESULT
	`lh1`.`user_id` AS `user_id_competitor`
FROM
	`lobby_history` AS `lh1`
WHERE
	( `lh1`.`lobby_id` = ? ) AND
	( `lh1`.`user_id` <> ? )
GROUP BY
	1
LIMIT 1 ;
.
			$self->leave( $lobby_id , $user_id_competitor ) ;
		}
		
	}

	$self->log(
		'lobby_id' => $lobby_id ,
		'user_id' => $user_id ,
		'lobby_card_id' => $lobby_card_id ,
		'lobby_state_id' => $self->LOBBY_STATE_PASS
	) ;
}

sub leave( $$ ) {
	my ( $self , $user_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;
	my ( $lobby_id ) = $dbh->selectrow_array( << '.' , undef( ) , $user_id ) || return +( ) ;
SELECT
	`l1`.`id` AS `lobby_id`
FROM
	`lobby` AS `l1`
WHERE
	( ? IN ( `l1`.`user_id_creator` , `l1`.`user_id_competitor` ) ) AND
	( `l1`.`done` IS null )
LIMIT 1 ;
.

	return +( ) unless $dbh->selectrow_array( << '.' , undef( ) , $user_id , 1 , 2 , $lobby_id ) > 0 ;
UPDATE IGNORE
	`lobby` AS `l1`
SET
	`l1`.`done` := current_timestamp( ) ,
	`l1`.`won` := IF( ? = `l1`.`user_id_creator` , ? , ? )
WHERE
	( `l1`.`id` = ? ) AND
	( `l1`.`done` IS null ) ;
.
	$self->log(
		'lobby_id' => $lobby_id ,
		'user_id' => $user_id ,
		'lobby_state_id' => $self->LOBBY_STATE_ORPHANED
	) ;
}

sub subscribe( $$$ ) {
	my ( $self , $user_id , $lobby_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	return +( ) unless $dbh->do( << '.' , undef( ) , $user_id , $lobby_id ) > 0 ;
UPDATE IGNORE
	`lobby` AS `l1`
SET
	`l1`.`user_id_competitor` := ?
WHERE
	( `l1`.`lobby_id` = ? ) AND
	( `l1`.`user_id_competitor` IS null ) AND
	( `l1`.`done` IS null ) ;
.
	$self->log(
		'user_id' => $user_id ,
		'lobby_id' => $lobby_id ,
		'lobby_state_id' => $self->LOBBY_STATE_PLAYING
	) ;
}

sub log( $% ) {
	my ( $self , %args ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;
	my @keys = qw(lobby_id user_id lobby_card_id lobby_state_id) ;

	exists( $args{ $_ } ) or $args{ $_ } = undef( ) foreach @keys ;

	return +( ) unless $dbh->do( << '.' , undef( ) , @args{ @keys , qw(lobby_id user_id) } ) > 0 ;
INSERT IGNORE INTO
	`lobby_history`(
		`lobby_id` ,
		`user_id` ,
		`lobby_card_id` ,
		`lobby_state_id`
	)
SELECT
	? AS `lobby_id` ,
	? AS `user_id` ,
	? AS `lobby_card_id` ,
	? AS `lobby_state_id`
FROM
	`lobby` AS `l1`
WHERE
	( `l1`.`id` = ? ) AND
	( `l1`.`done` IS null ) AND (
		( `l1`.`user_id_competitor` IS null ) OR
		( ? IN ( `l1`.`user_id_creator` , `l1`.`user_id_competitor` ) )
	)
LIMIT 1 ;
.
	$self->__last_insert_id( ) ;
}

sub create( $$ ) {
	my ( $self , $user_id ) = @_ ;
	my $dbh = $self->__dbh( ) || return +( ) ;

	return +( ) if $dbh->selectrow_array( << '.' , undef( ) , $user_id ) > 0 ;
SELECT
	`l1`.`id` AS `lobby_id`
FROM
	`lobby` AS `l1`
WHERE
	( ? IN ( `l1`.`user_id_competitor` , `l1`.`user_id_creator` ) ) AND
	( `l1`.`done` IS null ) ;
.
	return +( ) unless $dbh->do( << '.' , undef( ) , $user_id ) > 0 ;
INSERT INTO
	`lobby`(
		`user_id_creator`
	)
SELECT
	`vuo1`.`user_id`
FROM
	`v_user_online` AS `vuo1`
WHERE
	( `vuo1`.`user_id` = ? )
LIMIT 1 ;
.
	$self->__last_insert_id( ) ;
}