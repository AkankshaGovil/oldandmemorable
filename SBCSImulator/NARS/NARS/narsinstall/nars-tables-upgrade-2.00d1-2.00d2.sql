
#######
##### DO NOT USE THIS, more work need to be done
#######


use nars;

alter table cdrs modify column MSW_ID VARCHAR(64) NOT NULL;
alter table cdrs modify column Status_Desc VARCHAR(96) NOT NULL;
alter table cdrs change column Orig_Line Source_Q931_Port MEDIUMINT NOT NULL;
alter table cdrs drop   column Term_Line;
alter table cdrs modify column User_ID VARCHAR(32);
alter table cdrs modify column Call_E164 VARCHAR(64) NOT NULL;
alter table cdrs modify column Call_DTMF VARCHAR(64) NOT NULL;
alter table cdrs modify column Call_Type VARCHAR(4) NOT NULL;
alter table cdrs drop   column Call_Parties;
alter table cdrs modify column Disc_Code VARCHAR(2) NOT NULL;
alter table cdrs modify column Err_Desc VARCHAR(96);
alter table cdrs drop   column Fax_Pages;
alter table cdrs drop   column Fax_Pri;
alter table cdrs modify column ANI VARCHAR(64);
alter table cdrs drop   column DNIS;
alter table cdrs drop   column Bytes_Sent;
alter table cdrs drop   column Bytes_Recv;
alter table cdrs drop   column GW_Stop;
alter table cdrs modify column Orig_GW VARCHAR(72) NOT NULL;
alter table cdrs modify column Term_GW VARCHAR(72) NOT NULL;
alter table cdrs modify column Last_Call_Number VARCHAR(64) NOT NULL;
alter table cdrs modify column Err2_Desc VARCHAR(96);
alter table cdrs modify column Last_Event VARCHAR(96);
alter table cdrs modify column New_ANI VARCHAR(64) NOT NULL;
alter table cdrs drop   column Duration_Sec;
alter table cdrs add index Orig_GW_Combo (Orig_GW,Orig_Port,Date_Time,Term_GW,Term_Port,Disc_Code);
alter table cdrs add index Orig_IP_Combo (Orig_IP,Orig_Port,Date_Time,Term_IP,Term_Port,Disc_Code);
alter table cdrs add index Term_Gw_Port (Term_GW, Term_Port);
alter table cdrs add index Term_IP_Port (Term_IP,Term_Port);
alter table cdrs add index Status (Status);

########alter table ratedcdr add column;
alter table ratedcdr modify column SellCompanyID VARCHAR(64);
alter table ratedcdr modify column BuyCompanyID VARCHAR(64);
alter table ratedcdr modify column DialedNum VARCHAR(64) NOT NULL;
alter table ratedcdr modify column ManipDialed VARCHAR(64) NOT NULL;
alter table ratedcdr modify column CallType VARCHAR(4) NOT NULL;
alter table ratedcdr modify column DisconnectReason VARCHAR(2) NOT NULL;
alter table ratedcdr modify column OrigGW VARCHAR(72) NOT NULL;
alter table ratedcdr modify column TermGW VARCHAR(72) NOT NULL;
###########alter table ratedcdr add index PRIMARY;
###########alter table ratedcdr change index UniqueID;
alter table ratedcdr add index OrigGW_Combo (OrigGW, OrigPort, Date_Time, TermGW, TermPort, BillableFlag);
alter table ratedcdr add index OrigIP_Combo (OrigIP, OrigPort, Date_Time, TermIP, TermPort, BillableFlag);
alter table ratedcdr add index Date_Time_Bill (Date_Time, BillableFlag);
##########alter table ratedcdr drop index Date_Time;
alter table ratedcdr add index OrigDesc (OrigDesc);
alter table ratedcdr add index OrigCountry (OrigCountry);
alter table ratedcdr add index SellID (SellID);
alter table ratedcdr add index BuyerID (BuyerID);
alter table ratedcdr add index SellPlanID (SellPlanID);
alter table ratedcdr add index BuyPlanID (BuyPlanID);
alter table ratedcdr add index TermIP_Port (TermIP, TermPort);
