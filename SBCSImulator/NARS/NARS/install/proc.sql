 use mysql;
 CREATE TABLE `proc` (
     `db` char(64) character set utf8 collate utf8_bin NOT NULL default '',
     `name` char(64) NOT NULL default '',
     `type` enum('FUNCTION','PROCEDURE') NOT NULL,
     `specific_name` char(64) NOT NULL default '',
     `language` enum('SQL') NOT NULL default 'SQL',
     `sql_data_access` enum('CONTAINS_SQL','NO_SQL','READS_SQL_DATA','MODIFIES_SQL_DATA') NOT NULL default 'CONTAINS_SQL',
     `is_deterministic` enum('YES','NO') NOT NULL default 'NO',
      `security_type` enum('INVOKER','DEFINER') NOT NULL default 'DEFINER',
     `param_list` blob NOT NULL,
     `returns` char(64) NOT NULL default '',
     `body` longblob NOT NULL,
     `definer` char(77) character set utf8 collate utf8_bin NOT NULL default '',
      `created` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
     `modified` timestamp NOT NULL default '0000-00-00 00:00:00',
     `sql_mode` set('REAL_AS_FLOAT','PIPES_AS_CONCAT','ANSI_QUOTES','IGNORE_SPACE','NOT_USED','ONLY_FULL_GROUP_BY',
     'NO_UNSIGNED_SUBTRACTION'
     ,'NO_DIR_IN_CREATE','POSTGRESQL','ORACLE','MSSQL','DB2','MAXDB','NO_KEY_OPTIONS','NO_TABLE_OPTIONS',
     'NO_FIELD_OPTIONS',
     'MYSQL323','MYSQL40','ANSI','NO_AUTO_VALUE_ON_ZERO','NO_BACKSLASH_ESCAPES','STRICT_TRANS_TABLES','STRICT_ALL_TABLES',
     'NO_ZERO_IN_DATE',
     'NO_ZERO_DATE','INVALID_DATES','ERROR_FOR_DIVISION_BY_ZERO','TRADITIONAL','NO_AUTO_CREATE_USER',
     'HIGH_NOT_PRECEDENCE') NOT NULL default '',
     `comment` char(64) character set utf8 collate utf8_bin NOT NULL default '',
     PRIMARY KEY  (`db`,`name`,`type`)
     ) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Stored Procedures'
     ;
