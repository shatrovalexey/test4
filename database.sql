-- MySQL dump 10.13  Distrib 5.7.19, for Linux (x86_64)
--
-- Host: localhost    Database: test4
-- ------------------------------------------------------
-- Server version	5.7.19-0ubuntu0.16.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `entity`
--

DROP TABLE IF EXISTS `entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entity` (
  `name` varchar(20) NOT NULL,
  `value` varchar(1000) NOT NULL,
  `description` varchar(100) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entity`
--

LOCK TABLES `entity` WRITE;
/*!40000 ALTER TABLE `entity` DISABLE KEYS */;
INSERT INTO `entity` VALUES ('pass.expires','5','Expiration period for the pass in sec'),('session.expires','3600','Expiration period for the session in sec');
/*!40000 ALTER TABLE `entity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lobby`
--

DROP TABLE IF EXISTS `lobby`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby` (
  `id` bigint(22) unsigned NOT NULL AUTO_INCREMENT,
  `user_id_creator` bigint(22) unsigned NOT NULL,
  `user_id_competitor` bigint(22) unsigned DEFAULT NULL,
  `winner` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `done` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id_creator_done_UNIQUE` (`user_id_creator`,`done`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lobby`
--

LOCK TABLES `lobby` WRITE;
/*!40000 ALTER TABLE `lobby` DISABLE KEYS */;
/*!40000 ALTER TABLE `lobby` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lobby_card`
--

DROP TABLE IF EXISTS `lobby_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_card` (
  `id` tinyint(1) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lobby_card`
--

LOCK TABLES `lobby_card` WRITE;
/*!40000 ALTER TABLE `lobby_card` DISABLE KEYS */;
INSERT INTO `lobby_card` VALUES (1,'stone'),(2,'paper'),(3,'clips'),(4,'lizard'),(5,'spok');
/*!40000 ALTER TABLE `lobby_card` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lobby_card_priority`
--

DROP TABLE IF EXISTS `lobby_card_priority`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_card_priority` (
  `lobby_card_id_greater` tinyint(1) unsigned NOT NULL,
  `lobby_card_id_smaller` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`lobby_card_id_greater`,`lobby_card_id_smaller`),
  KEY `fk_lobby_card_id_smaller_idx` (`lobby_card_id_smaller`),
  CONSTRAINT `fk_lobby_card_priority_lobby_card_id_greater` FOREIGN KEY (`lobby_card_id_greater`) REFERENCES `lobby_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lobby_card_priority_lobby_card_id_smaller` FOREIGN KEY (`lobby_card_id_smaller`) REFERENCES `lobby_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lobby_card_priority`
--

LOCK TABLES `lobby_card_priority` WRITE;
/*!40000 ALTER TABLE `lobby_card_priority` DISABLE KEYS */;
/*!40000 ALTER TABLE `lobby_card_priority` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lobby_history`
--

DROP TABLE IF EXISTS `lobby_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_history` (
  `id` bigint(22) unsigned NOT NULL AUTO_INCREMENT,
  `lobby_id` bigint(22) unsigned NOT NULL,
  `user_id` bigint(22) unsigned NOT NULL,
  `lobby_card_id` tinyint(1) unsigned DEFAULT NULL,
  `lobby_state_id` tinyint(1) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `lobby_id_idx` (`lobby_id`),
  KEY `fk_lobby_state_id_idx` (`lobby_state_id`),
  KEY `fk_lobby_history_user_id_idx` (`user_id`),
  KEY `fk_lobby_history_card_id_idx` (`lobby_card_id`),
  CONSTRAINT `fk_lobby_history_lobby_card_id` FOREIGN KEY (`lobby_card_id`) REFERENCES `lobby_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lobby_history_lobby_id` FOREIGN KEY (`lobby_id`) REFERENCES `lobby` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lobby_history_state_id` FOREIGN KEY (`lobby_state_id`) REFERENCES `lobby_state` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lobby_history_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lobby_history`
--

LOCK TABLES `lobby_history` WRITE;
/*!40000 ALTER TABLE `lobby_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `lobby_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lobby_state`
--

DROP TABLE IF EXISTS `lobby_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lobby_state` (
  `id` tinyint(1) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lobby_state`
--

LOCK TABLES `lobby_state` WRITE;
/*!40000 ALTER TABLE `lobby_state` DISABLE KEYS */;
INSERT INTO `lobby_state` VALUES (1,'waiting'),(2,'playing'),(3,'done'),(4,'pass'),(5,'orphaned');
/*!40000 ALTER TABLE `lobby_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `id` char(32) NOT NULL,
  `user_id` bigint(22) unsigned NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expires` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_session_user_id_idx` (`user_id`),
  CONSTRAINT `fk_session_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` bigint(22) unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(40) NOT NULL,
  `passwd` char(32) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_UNIQUE` (`login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_UNSIGNED_SUBTRACTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `test4`.`user_BEFORE_INSERT` BEFORE INSERT ON `user` FOR EACH ROW
BEGIN
	SET new.`login` := trim( coalesce( new.`login` , md5( uuid( ) ) ) ) ;
	SET new.`passwd` := md5( uuid( ) ) ;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_UNSIGNED_SUBTRACTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`%`*/ /*!50003 TRIGGER `test4`.`user_BEFORE_UPDATE` BEFORE UPDATE ON `user` FOR EACH ROW
BEGIN
	SET new.`login` := trim( coalesce( new.`login` , md5( uuid( ) ) ) ) ;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary table structure for view `v_user_online`
--

DROP TABLE IF EXISTS `v_user_online`;
/*!50001 DROP VIEW IF EXISTS `v_user_online`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `v_user_online` AS SELECT 
 1 AS `user_id`,
 1 AS `session_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'test4'
--
/*!50003 DROP FUNCTION IF EXISTS `fs_entity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_UNSIGNED_SUBTRACTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fs_entity`(
	`in_name` VARCHAR( 40 )
) RETURNS text CHARSET utf8mb4
BEGIN
	RETURN (
		SELECT
			`e1`.`value` AS `result`
        FROM
			`entity` AS `e1`
		WHERE
			( `e1`.`name` = `in_name` )
		LIMIT 1
    ) ;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fs_expired` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_UNSIGNED_SUBTRACTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fs_expired`(
	`in_datetime` DATETIME
) RETURNS tinyint(1) unsigned
RETURN unix_timestamp( ) - unix_timestamp( `in_datetime` ) > `fs_entity`( 'pass.expires' ) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fs_expires` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_UNSIGNED_SUBTRACTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `fs_expires`() RETURNS datetime
    DETERMINISTIC
RETURN from_unixtime( `fs_entity`( 'session.expires' ) + unix_timestamp( ) ) ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_user_online`
--

/*!50001 DROP VIEW IF EXISTS `v_user_online`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_online` AS select sql_small_result `s1`.`user_id` AS `user_id`,`s1`.`id` AS `session_id` from (`user` `u1` join `session` `s1` on((`s1`.`user_id` = `u1`.`id`))) where (`s1`.`expires` > now()) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-08-20  2:34:31
