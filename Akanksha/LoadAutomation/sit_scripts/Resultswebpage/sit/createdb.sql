DROP DATABASE IF EXISTS testdb;
CREATE DATABASE testdb;
USE testdb;

DROP TABLE IF EXISTS tests;
CREATE TABLE `tests` (
  `Id` int(11) NOT NULL auto_increment,
  `Created` datetime NOT NULL,
  `TestStart` datetime NOT NULL,
  `TestEnd` datetime NOT NULL,
  `Product` enum('MSX','SBC','RSM','IBG') NOT NULL default 'MSX',
  `MajorVersion` varchar(16) NOT NULL,
  `SUTVersion` varchar(256) NOT NULL,
  `TestStatus` enum('Completed','In Progress','Aborted') NOT NULL,
  `TestType` enum('Nightly','Full','Load') NOT NULL default 'Full',
  `NumTests` int(11) NOT NULL,
  `NumPass` int(11) NOT NULL,
  `SystemHW` enum('IBG-2S','Jarrell','Annapolis') NOT NULL default 'Jarrell',
  `MediaHW` enum('N/A','HK','NP2','NP2Pass3','NP2G') NOT NULL default 'NP2G',
  `DetailsKey` varchar(64) NOT NULL,
  `LastModified` datetime NOT NULL,
  `NextestVersion` varchar(256) NOT NULL,
  `Contact` varchar(256) default NULL,
  `Comments` text,
  PRIMARY KEY  (`Id`),
  KEY `TestStart` (`TestStart`,`TestEnd`,`MajorVersion`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1


DROP TABLE IF EXISTS details;
CREATE TABLE `details` (
  `Id` int(11) NOT NULL auto_increment,
  `TestId` int(11) NOT NULL,
  `Details` varchar(64) NOT NULL,
  `DisplayString` varchar(128) NOT NULL,
  `RelativePath` varchar(256) NOT NULL,
  PRIMARY KEY  (`Id`),
  KEY `Details` (`Details`),
  CONSTRAINT `details_ibfk_1` FOREIGN KEY (`TestId`) REFERENCES `tests` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1

