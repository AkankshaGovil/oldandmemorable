DELIMITER $$


update msws set MSWIp = INET_NTOA(MSWIp);$$
update sessions set ip = INET_NTOA(ip);$$
	   
update rsmalarm set MSWIp = INET_NTOA(MSWIp);$$
update rsmevent set MSWIp = INET_NTOA(MSWIp);$$
update rsmalarm_memory set MSWIp = INET_NTOA(MSWIp);$$

update endpoints set IpAddrType = 4, SubnetIpType = 4, SubnetMaskType = 4, sctp_addr1Type = 4, sctp_addr2Type = 4, sctp_addr3Type = 4;$$
update realms set RsaType = 4, MaskType = 4, ipsecExtGwIPType = 4;$$	
update subnets set IPAddressType = 4, MaskType = 4, GatewayType = 4;$$	
update blacklist_ips set DIPAddressType = 4, SIPAddressType = 4, SIPAddressv6 = 0x00000000000000000000000000000000;$$	
update dns_resolvers set Dns_Server_ipAddrType = 4;$$
# for PR169113: revert version
update endpoints set Version = Version-1;$$
update realms set Version = Version-1;$$
update subnets set Version = Version-1;$$
update blacklist_ips set Version = Version-1;$$
update dns_resolvers set Version = Version-1;$$

DROP PROCEDURE IF EXISTS updatePMTable;$$
CREATE PROCEDURE updatePMTable()
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName varchar(65);
    DECLARE tableName_cursor CURSOR FOR SELECT distinct table_name FROM information_schema.tables WHERE (table_schema = 'bn') and (table_name LIKE 'PerformanceStatsData%') and table_name not in ('PerformanceStatsDataLogs');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN tableName_cursor;
    FETCH NEXT FROM tableName_cursor INTO tableName;
    WHILE done = 0 DO
        set @sql = CONCAT("update ", tableName, " set MSWIp = INET_NTOA(MSWIp)");
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        FETCH NEXT FROM tableName_cursor INTO tableName;
    END WHILE;
    CLOSE tableName_cursor;
END $$
call updatePMTable();$$
DROP PROCEDURE IF EXISTS updatePMTable;$$
#DELIMITER ;

# function 'INET_NSTOAS' is for feature 'video indicator in CDR feature', PR-158531
#DELIMITER $$
DROP FUNCTION IF EXISTS INET_NSTOAS;$$
CREATE FUNCTION INET_NSTOAS(
nIPs TEXT, 
delim VARCHAR(10)
)
RETURNS TEXT 
DETERMINISTIC
BEGIN
	DECLARE foundPos INT;
	DECLARE tmpTxt TEXT;
	DECLARE element TEXT;
	DECLARE aIPs TEXT;

	set aIPs = '';
	set tmpTxt = nIPs;	
	set foundPos = INSTR(tmpTxt,delim);
	IF foundPos = 0 THEN
      set aIPs = INET_NTOA(nIPs);
    ELSE    
		WHILE foundPos <> 0 DO
			set element = SUBSTRING(tmpTxt, 1, foundPos-1);
			set tmpTxt = REPLACE(tmpTxt, concat(element,delim), '');		
			set foundPos = instr(tmpTxt,delim);
			IF foundPos <> 0 THEN
			  set aIPs = CONCAT(aIPs, INET_NTOA(element), delim);
			ELSE
			  set aIPs = CONCAT(aIPs, INET_NTOA(element), delim, INET_NTOA(tmpTxt));
			END IF;
		END WHILE;
    END IF;
	
    RETURN aIPs;
END $$
#DELIMITER ;

#DELIMITER $$
DROP PROCEDURE IF EXISTS updateCDRTable;$$
CREATE PROCEDURE updateCDRTable()
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE tableName varchar(25);
    DECLARE tableName_cursor CURSOR FOR SELECT distinct table_name FROM information_schema.tables WHERE (table_schema = 'bn') and (table_name LIKE 'cdr%' or table_name LIKE 'sellsummary%' or table_name LIKE 'buysummary%' or table_name LIKE 'hrsum_%' or table_name like 'hrsell_%' or table_name like 'hrbuy_%') and table_name not in ('cdrfiles', 'cdrlogs');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN tableName_cursor;
    FETCH NEXT FROM tableName_cursor INTO tableName;
    WHILE done = 0 DO
        IF tableName REGEXP '^cdr[0-9]*$' THEN
            set @sql = CONCAT("update ", tableName, " set OrigIp = INET_NTOA(OrigIp), TermIp = INET_NTOA(TermIp), SrcPrivateIp = INET_NSTOAS(SrcPrivateIp, ','), DstPrivateIp = INET_NSTOAS(DstPrivateIp, ','), SrcRealmMediaIP = INET_NSTOAS(SrcRealmMediaIP, ','), DstRealmMediaIP = INET_NSTOAS(DstRealmMediaIP, ',')");
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        ELSE
            set @sql = CONCAT("update ", tableName, " set OrigIp = INET_NTOA(OrigIp), TermIp = INET_NTOA(TermIp)");
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF; 
        FETCH NEXT FROM tableName_cursor INTO tableName;
    END WHILE;
    CLOSE tableName_cursor;
END $$
call updateCDRTable();$$
DROP PROCEDURE IF EXISTS updateCDRTable;$$
DROP FUNCTION IF EXISTS INET_NSTOAS;$$
#DELIMITER ;


DELIMITER ;
