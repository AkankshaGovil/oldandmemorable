#additional database script for PHPSCHEDULEIT
use phpScheduleIt;

#create machines table
DROP TABLE IF EXISTS machines;
CREATE TABLE machines (
  machineid INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  machinename VARCHAR(25) NOT NULL,
  machineip CHAR(16) NOT NULL,
  machinetype CHAR(16),
  SystemHW enum('IBG-2S','Jarrell','Annapolis') default 'Jarrell',
  mediahwtype ENUM ('N/A','HK','NP2','NP2Pass3','NP2G'),
  comments VARCHAR(100),
  machid CHAR(25),
  CONSTRAINT machines_ibfk_1 FOREIGN KEY (machid) REFERENCES resources (machid)
  );
