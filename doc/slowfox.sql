-- MySQL dump 10.13  Distrib 5.5.31, for Linux (x86_64)
--
-- Host: localhost    Database: slowfox
-- ------------------------------------------------------
-- Server version	5.5.31-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'Nom de l''utilisateur',
  `societe` varchar(100) DEFAULT NULL,
  `firstname` varchar(255) NOT NULL COMMENT 'Prénom de l''utilisateur',
  `login` varchar(255) NOT NULL COMMENT 'Login /email utilisateur',
  `password` varchar(255) NOT NULL COMMENT 'password salé',
  `roles` varchar(1000) NOT NULL,
  `lastip` varchar(16) DEFAULT NULL COMMENT 'dernère ip de connexion',
  `lastconnexion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `disable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_login` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'NAME','CORP.','Fistname','admin@admin.fr','$2a$10$AIfoBACaIDjYUc1yLfO3ouoemQFC12Zd1Tvoj5g1aandML1cj7ktO','admin,guests,user,voip','192.168.0.19','2014-06-03 19:08:10',0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `voip`
--

DROP TABLE IF EXISTS `voip`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `voip` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `username` varchar(30) DEFAULT NULL,
  `type` varchar(6) NOT NULL DEFAULT 'peer',
  `secret` varchar(50) DEFAULT NULL,
  `md5secret` varchar(32) DEFAULT NULL,
  `dbsecret` varchar(100) DEFAULT NULL,
  `notransfer` varchar(10) DEFAULT NULL,
  `inkeys` varchar(100) DEFAULT NULL,
  `outkey` varchar(100) DEFAULT NULL,
  `auth` varchar(100) DEFAULT 'md5',
  `accountcode` varchar(100) DEFAULT NULL,
  `amaflags` varchar(100) DEFAULT NULL,
  `callerid` varchar(100) DEFAULT NULL,
  `context` varchar(100) DEFAULT NULL,
  `defaultip` varchar(15) DEFAULT NULL,
  `host` varchar(31) NOT NULL DEFAULT 'dynamic',
  `language` char(5) DEFAULT 'fr',
  `mailbox` varchar(50) DEFAULT NULL,
  `deny` varchar(95) DEFAULT NULL,
  `permit` varchar(95) DEFAULT NULL,
  `qualify` varchar(4) DEFAULT 'yes',
  `disallow` enum('all') DEFAULT 'all',
  `allow` enum('ilbc') DEFAULT 'ilbc',
  `ipaddr` varchar(45) DEFAULT NULL,
  `port` int(11) DEFAULT '4569',
  `regseconds` int(11) DEFAULT '60',
  PRIMARY KEY (`name`,`id`),
  UNIQUE KEY `idx_id` (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `voip`
--

LOCK TABLES `voip` WRITE;
/*!40000 ALTER TABLE `voip` DISABLE KEYS */;
INSERT INTO `voip` VALUES (1,'FistnameNAME','FistnameNAME','peer','eliott','69fa49c85011f757dd8ed923c816ab7c',NULL,NULL,NULL,NULL,'md5',NULL,NULL,'Fistname NAME<10>','context',NULL,'dynamic','fr',NULL,NULL,NULL,'yes','all','ilbc',NULL,51324,0);
/*!40000 ALTER TABLE `voip` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-06-04  9:24:49
