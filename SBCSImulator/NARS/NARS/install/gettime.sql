use bn;
DROP FUNCTION bn.GETTIME;

delimiter |
CREATE FUNCTION bn.GETTIME (n1 varchar(32))   RETURNS varchar(32)    

deterministic     
BEGIN      
DECLARE zone INT;   
DECLARE zonestr varchar(32);
DECLARE zoneutc varchar(32);
DECLARE zonehourmod INT;
DECLARE zonehour INT;
DECLARE i INT;

SET zonestr = n1;
IF n1 is NULL OR n1="local0" OR n1="" 
THEN 
set zoneutc="SYSTEM"; 
ELSE
SET zone = n1;
SET zonehourmod = zone % 60;
SET zonehour = (abs(zone)-zonehourmod)/60;
IF zonehourmod = 0 
THEN
SET zoneutc =  concat(zonehour,":00");
ELSE
SET zoneutc =  concat(zonehour,":",zonehourmod) ;
END IF;
SET i = locate("-",zonestr);
IF i = 0 
THEN
SET zoneutc = concat("+",zoneutc);
ELSE
SET zoneutc = concat("-",zoneutc);
END IF;
END IF;
return zoneutc;
END;
|

DELIMITER ;
