DELIMITER $$

#DELIMITER $$
DROP PROCEDURE IF EXISTS alterIPv4Field;$$
CREATE PROCEDURE alterIPv4Field()
DETERMINISTIC
BEGIN
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'msws' and column_name = 'MSWIp' and column_type = 'varchar(46)') THEN
        alter table msws change MSWIp MSWIp varchar(46) not null default '', change MswDB MswDB varchar(46) not null default '';
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'sessions' and column_name = 'ip' and column_type = 'varchar(46)') THEN
        alter table sessions change ip ip varchar(46) default '';
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'trails' and column_name = 'ClientAddr' and column_type = 'varchar(46)') THEN
        alter table trails change ClientAddr ClientAddr varchar(46) NOT NULL default '';
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'rsmalarm' and column_name = 'MSWIp' and column_type = 'varchar(46)') THEN
        alter table rsmalarm change MSWIp MSWIp varchar(46) NOT NULL default '';
    END IF; 
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'rsmevent' and column_name = 'MSWIp' and column_type = 'varchar(46)') THEN
        alter table rsmevent change MSWIp MSWIp varchar(46) NOT NULL default '';
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'rsmalarm_memory' and column_name = 'MSWIp' and column_type = 'varchar(46)') THEN
        alter table rsmalarm_memory change MSWIp MSWIp varchar(46) NOT NULL default '';
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'TrapSentToNB' and column_name = 'DeviceIp' and column_type = 'varchar(46)') THEN
        alter table TrapSentToNB change DeviceIp DeviceIp varchar(46) default NULL, change NBIPaddress NBIPaddress varchar(46) NOT NULL default '';
    END IF;
END $$
call alterIPv4Field();$$
DROP PROCEDURE IF EXISTS alterIPv4Field;$$
#DELIMITER ;

#DELIMITER $$
DROP PROCEDURE IF EXISTS addIPv6Field;$$
CREATE PROCEDURE addIPv6Field()
DETERMINISTIC
BEGIN
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'endpoints' and column_name = 'IpAddrv6') THEN
       alter table endpoints add column IpAddrv6 binary(16) default null, add column IpAddrType int default 0, add column SubnetIpv6 binary(16) default null, add column SubnetIpType int default 0, add column SubnetMaskv6 bigint, add column SubnetMaskType int default 0, add column sctp_Addr1v6 binary(16) default null, add column sctp_addr1Type int default 0, add column sctp_Addr2v6 binary(16) default null, add column sctp_addr2Type int default 0, add column sctp_Addr3v6 binary(16) default null, add column sctp_addr3Type int default 0;
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'realms' and column_name = 'Rsav6') THEN
       alter table realms add column Rsav6 binary(16) default null, add column RsaType int default 0, add column Maskv6 bigint, add column MaskType int default 0, add column ipsecExtGwIPv6 binary(16) default null, add column ipsecExtGwIPType int default 0;
    END IF; 
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'vnet' and column_name = 'ipver') THEN
       alter table vnet add column ipver smallint(6) not null default 4;
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'subnets' and column_name = 'IPaddressv6') THEN
       alter table subnets add column IPaddressv6 binary(16) default null, add column IPAddressType int(11) default 0, add column Maskv6 bigint, add column MaskType int(11) default 0, add column Gatewayv6 binary(16) default null, add column GatewayType int(11) default 0;
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'blacklist_ips' and column_name = 'DIPAddressv6') THEN
       alter table blacklist_ips add column DIPAddressv6 binary(16) default null, add column DIPAddressType int default 0, add column SIPAddressv6 binary(16) default null, add column SIPAddressType int default 0, drop index ClusterId, add unique ClusterId (ClusterId, SIPAddress, SIPAddressv6, RealmName, SrcPort);
    END IF;
    
    IF NOT EXISTS (select column_name from information_schema.columns where table_schema = 'bn' and table_name = 'dns_resolvers' and column_name = 'Dns_Server_Ipaddrv6') THEN
       alter table dns_resolvers add column Dns_Server_Ipaddrv6 binary(16), add column Dns_Server_ipAddrType int(11) default 0;
    END IF;
END $$
call addIPv6Field();$$
DROP PROCEDURE IF EXISTS addIPv6Field;$$
#DELIMITER ;

DROP PROCEDURE IF EXISTS alterPMTable;$$
CREATE PROCEDURE alterPMTable()
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName varchar(65);
    DECLARE tableName_cursor CURSOR FOR SELECT distinct table_name FROM information_schema.tables WHERE (table_schema = 'bn') and (table_name LIKE 'PerformanceStatsData%') and table_name not in ('PerformanceStatsDataLogs');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN tableName_cursor;
    FETCH NEXT FROM tableName_cursor INTO tableName;
    WHILE done = 0 DO
        set @sql = CONCAT("alter table ", tableName, " change MSWIp MSWIp varchar(46) NOT NULL default ''");
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        FETCH NEXT FROM tableName_cursor INTO tableName;
    END WHILE;
    CLOSE tableName_cursor;
END $$
call alterPMTable();$$
DROP PROCEDURE IF EXISTS alterPMTable;$$
#DELIMITER ;

#DELIMITER $$
DROP PROCEDURE IF EXISTS alterCDRTable;$$
CREATE PROCEDURE alterCDRTable()
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName varchar(25);
    DECLARE tableName_cursor CURSOR FOR SELECT distinct table_name FROM information_schema.columns WHERE (table_schema = 'bn') and (table_name LIKE 'cdr%' or table_name LIKE 'sellsummary%' or table_name LIKE 'buysummary%' or table_name LIKE 'hrsum_%' or table_name like 'hrsell_%' or table_name like 'hrbuy_%') and table_name not in ('cdrfiles', 'cdrlogs') and column_name = 'OrigIp' and column_type != 'varchar(46)';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN tableName_cursor;
    FETCH NEXT FROM tableName_cursor INTO tableName;
    WHILE done = 0 DO
        IF tableName REGEXP '^cdr[0-9]*$' THEN
            set @sql = CONCAT("alter table ", tableName, " change OrigIp OrigIp varchar(46) NOT NULL default '', change TermIp TermIp varchar(46) NOT NULL default '', change SrcPrivateIp SrcPrivateIp varchar(150) NOT NULL default '', change DstPrivateIp DstPrivateIp varchar(150) NOT NULL default '', change SrcRealmMediaIP SrcRealmMediaIP varchar(150) NOT NULL default '', change DstRealmMediaIP DstRealmMediaIP varchar(150) NOT NULL default '', change SrcPrivatePort SrcPrivatePort varchar(25) NOT NULL default '', change DestPrivatePort DestPrivatePort varchar(25) NOT NULL default '', change SrcRealmMediaPort SrcRealmMediaPort varchar(25) NOT NULL default '', change DstRealmMediaPort DstRealmMediaPort varchar(25) NOT NULL default ''");
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            FETCH NEXT FROM tableName_cursor INTO tableName;
        ELSE
            set @sql = CONCAT("alter table ", tableName, " change OrigIp OrigIp varchar(46) NOT NULL default '', change TermIp TermIp varchar(46) NOT NULL default ''");
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF; 
        FETCH NEXT FROM tableName_cursor INTO tableName;
    END WHILE;
    CLOSE tableName_cursor;
END $$
call alterCDRTable();$$
DROP PROCEDURE IF EXISTS alterCDRTable;$$
DROP FUNCTION IF EXISTS INET_NSTOAS;$$
#DELIMITER ;

DELIMITER ;
