/*
SQLyog Enterprise - MySQL GUI v7.02 
MySQL - 5.0.41-community-nt : Database - twit_io
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/`twit_io` /*!40100 DEFAULT CHARACTER SET latin1 */;

USE `twit_io`;

/*Table structure for table `comments` */

DROP TABLE IF EXISTS `comments`;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL auto_increment,
  `users_id` int(11) default NULL,
  `upload_file_id` int(11) default NULL,
  `comments` text collate latin1_general_ci,
  `created_at` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

/*Table structure for table `contents` */

DROP TABLE IF EXISTS `contents`;

CREATE TABLE `contents` (
  `id` int(11) NOT NULL auto_increment,
  `content_type` varchar(255) collate latin1_general_ci default NULL,
  `content_name` varchar(255) collate latin1_general_ci default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

/*Table structure for table `schema_migrations` */

DROP TABLE IF EXISTS `schema_migrations`;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Table structure for table `upload_files` */

DROP TABLE IF EXISTS `upload_files`;

CREATE TABLE `upload_files` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) default NULL,
  `content_id` int(11) default NULL,
  `title` text collate latin1_general_ci,
  `name` text collate latin1_general_ci,
  `description` text collate latin1_general_ci,
  `created_at` timestamp NULL default NULL,
  `original_file_name` varchar(255) collate latin1_general_ci default NULL,
  `file_size` varchar(255) collate latin1_general_ci default NULL,
  `height` varchar(255) collate latin1_general_ci default NULL,
  `width` varchar(255) collate latin1_general_ci default NULL,
  `status` varchar(255) collate latin1_general_ci default NULL,
  `converted_file_name` varchar(255) collate latin1_general_ci default NULL,
  `thumbnail` text collate latin1_general_ci,
  `large_thumb` text collate latin1_general_ci,
  `drop_name` varchar(255) collate latin1_general_ci default NULL,
  `hidden_url` text collate latin1_general_ci,
  `updated_at` timestamp NOT NULL default '0000-00-00 00:00:00',
  `file_path` text collate latin1_general_ci,
  `view_count` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC;

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `twitter_id` varchar(255) default NULL,
  `login` varchar(255) default NULL,
  `access_token` varchar(255) default NULL,
  `access_secret` varchar(255) default NULL,
  `remember_token` varchar(255) default NULL,
  `remember_token_expires_at` datetime default NULL,
  `name` varchar(255) default NULL,
  `location` varchar(255) default NULL,
  `description` varchar(255) default NULL,
  `profile_image_url` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `drop_name` varchar(255) default NULL,
  `protected` tinyint(1) default NULL,
  `profile_background_color` varchar(255) default NULL,
  `profile_sidebar_fill_color` varchar(255) default NULL,
  `profile_link_color` varchar(255) default NULL,
  `profile_sidebar_border_color` varchar(255) default NULL,
  `profile_text_color` varchar(255) default NULL,
  `profile_background_image_url` varchar(255) default NULL,
  `profile_background_tile` tinyint(1) default NULL,
  `friends_count` int(11) default NULL,
  `statuses_count` int(11) default NULL,
  `followers_count` int(11) default NULL,
  `favourites_count` int(11) default NULL,
  `utc_offset` int(11) default NULL,
  `time_zone` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
