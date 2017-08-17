
--ENDX TABLES 
---------------
set hive.execution.engine=tez; 
create database if not exists retaildb;
DROP TABLE retaildb.endxvisits;
CREATE EXTERNAL TABLE if not exists retaildb.endxvisits
(
  	groupDate date,
    groupKey string,
    VisitMember bigint,
    VisitSession string,
    VisitClub string,
    VisitTime string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/ENDX_tblVisits/2016/';



--Region table
DROP TABLE retaildb.region;
CREATE EXTERNAL TABLE if not exists retaildb.region
(
    Region  string,
    BallyNumber	string,
    BallyName  string,	
    EndxNumber  string,	
    EndxName  string,	
    FinCubeName  string,
    HRName  string,	
    Club  string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n' 
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/RegionMap'
TBLPROPERTIES ("skip.header.line.count"="1");



--EndxRTP Table
DROP TABLE retaildb.endxrtp;
CREATE EXTERNAL TABLE if not exists retaildb.endxrtp
(
    ConsolodatedGameID  string,
    trntabletype string,
    tableName  string,	
    rtp  float
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/endxRTP'
TBLPROPERTIES ("skip.header.line.count"="1");


--Player Transactions Table  
DROP TABLE retaildb.endxpltransactions;
CREATE EXTERNAL TABLE if not exists retaildb.endxpltransactions
(
  	groupDate date,
    GroupKey string,
	TrnNumber string, 
	TrnSessionDate string, 
	TrnClub string, 
	TrnMember string, 
	TrnTableType string, 
	TrnDrop bigint, 
	TrnWinLoss bigint,
	TrnTimeStamp string, 
	TrnCashOut string, 
	TrnPokerSpend string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/ENDX_tblPlayerTransactions/2016/';



--BALLY TABLES 
-----------------
--BallyRTP Table
DROP TABLE retaildb.ballyrtp;
CREATE EXTERNAL TABLE if not exists retaildb.ballyrtp
(
    gameid  string,
    rtp	float
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/ballyRTP'
TBLPROPERTIES ("skip.header.line.count"="1");



DROP TABLE retaildb.ballyrtp2;
CREATE EXTERNAL TABLE if not exists retaildb.ballyrtp2
(
    GameCode string,
    GameName string,	
    GameID string,
    rtp	float
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/BALLY_rtp'
TBLPROPERTIES ("skip.header.line.count"="1");



--tTableRating Table
DROP TABLE retaildb.ballyttablerating;
CREATE EXTERNAL TABLE if not exists retaildb.ballyttablerating
(
    GroupKeyDate date,
    GroupKeySource string,
    TranID string,
    PlayerId string,
    IsVoid string,
    TranCodeID string,
    GamingDt string,
    PostDtm string,
    DeptID string,
    CasinoID string,
    GameID string,
    PlayerTypeID string,
    RatingStartDtm string,
    RatingEndDtm string,
    RatingPeriodMinutes string,
    Plays string,
    Bet float,
    PaidOut string,
    TheorHoldPc string,
    TheorWin string,
    BasePts string,
    BonusPts string,
    BaseStubs string,
    BonusStubs string,
    EarnedAltComp string,
    CasinoWinCalcMethod string,
    CasinoWin string,
    AddToPartialPts string,
    CashBuyIn string,
    CreditBuyIn string,
    ChipBuyIn string,
    TranCode string,
    ModifiedDtm string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/BALLY_tTableRating/2016';


--tSlotRating Table
DROP TABLE retaildb.ballytslotrating;
CREATE EXTERNAL TABLE if not exists retaildb.ballytslotrating
(
  	groupDate date,
    GroupKey string,
	TranID string, 
    PlayerId string, 
    IsVoid string, 
    TranCodeID string, 
	GamingDt string, 
    PostDtm string, 
    DeptID string, 
    CasinoID string, 
	GameID string, 
    PlayerTypeID string, 
    RatingStartDtm string, 
    RatingEndDtm string, 
	RatingPeriodMinutes string, 
    Plays string, 
    Bet float, 
    PaidOut string, 
	TheorHoldPc string, 
    TheorWin float, 
    BasePts string, 
    BonusPts string, 
	BaseStubs string, 
    BonusStubs string, 
    EarnedAltComp string, 
    CasinoWinCalcMethod string, 
	CasinoWin string, 
    JackPot string, 
    AddToPartialPts string, 
    ModifiedDtm string, 
    CashBuyIn string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/BALLY_tSlotRating/2016';


--tPokerRating
DROP TABLE retaildb.ballytpokerrating;
CREATE EXTERNAL TABLE if not exists retaildb.ballytpokerrating
(
  	groupDate date,
    GroupKey string,
	TranID string, 
    PlayerId string, 
    IsVoid string, 
    TranCodeID string, 
	GamingDt string, 
    PostDtm string, 
    DeptID string, 
    CasinoID string, 
	GameID string, 
    PlayerTypeID string, 
    RatingStartDtm string, 
    RatingEndDtm string, 
    CashBuyIn float,
    CreditBuyIn string, 
    ChipBuyIn string,
    PromoBuyIn string,
    ECreditBuyIn string, 
    RatingPeriodMinutes string, 
    Plays string, 
    Bet float, 
    PaidOut string, 
    TheorHoldPc string, 
    TheorWin string, 
    GamePts string, 
    BasePts string, 
    BonusPts string, 
    EarnedComp string, 
    BaseStubs string, 
    BonusStubs string,
    EarnedAltComp string, 
    Promo1 string, 
    BonusPromo1 string, 
    Promo2 string, 
    BonusPromo2 string, 
    CasinoWinCalcMethod string, 
    CasinoWin string, 
    MgmtRating string, 
    LocnMinBet string, 
    LocnMaxBet string, 
    CasinoStatistic string, 
    PartialPt1 string, 
    CreatedDtm string, 
    CreatedBy string, 
    ModifiedDtm string, 
    ModifiedBy string, 
    AddToPartialPts string, 
    AddToPartialPts2 string, 
    AddToPartialStubs string, 
    AddToPartialStubs2 string, 
    OldRelatedTranID string, 
    QualPts string, 
    SeatNo string, 
    FreqId string, 
    AdjBet string,
    AdjPaidOut string, 
    AdjTheorWin string, 
    AdjCasinoWin string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/BALLY_tPokerRating/2016';


DROP TABLE retaildb.ballytdrop;
CREATE EXTERNAL TABLE if not exists retaildb.ballytdrop
(
    GroupDate date, 
    GroupKey string, 
    venueCode string,
    venueDesc string,
    customerKey string,
    dayId_Drop string,
    dropHourOfDay string,
    sessCode string,
    sec_venueAreaCode string,
    sec_venueBrandCode string,
    dayDateTime string,
    FiscDayOfWeek string,
    FiscWeekDateTime string,
    FiscWeekOfYear string,
    FiscPeriodDateTime string,
    FiscPeriod string,
    FiscPeriodOfYear string,
    FiscQuarterDateTime string,
    FiscQuarterOfYear string,
    FiscQuarter string,
    FiscHalfDateTime string,
    FiscYearfDateTime string,
    FiscYear string,
    venueCity string,
    venueLat string,
    venueLong string,
    venueAreaDesc string,
    venueBrandDesc string,
    venueChannelDesc string,
    sessGroupName string,
    customerKey_INT string,
    customerBrand string,
    gender string,
    YearOfBirth string,
    age string,
    ageBand string,
    CRMEmailOptInRetail string,
    CRMEmailOptInOnline string,
    CRMPostalOptInRetail string,
    CRMPostalOptInOnline string,
    CRMSMSOptInRetail string,
    CRMSMSOptInOnline string,
    CRMTelephoneOptInRetail string,
    CRMTelephoneOptInOnline string,
    IsVIPRetail string,
    VIPLevelRetail string,
    IsVIPOnline string,
    VIPLevelOnline string,
    DropTotalAmount string,
    DropCashAmount string,
    DropChipAmount string,
    gameName string,
    gameGroupName string,
    gameTypeName string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/SAS_vw_LASR_Drop_GROS/2016';



DROP TABLE retaildb.rap_factgamingactivity;
CREATE EXTERNAL TABLE if not exists retaildb.rap_factgamingactivity
(
    GroupDate date, 
    GroupKey string,
	customerKey string,
	gameCode string,
	venueCode string,
	sessionCode string,
	dayId_CAL string,
	dayId_GAME string,
	gamingActivityIdSource string,
	sourceSystemCode string,
	amountStake string,
	amountFreeStake string,
	amountPayout string,
	playPointsBaseEarn string,
	playPointsBonusEarn string,
	datetimeGamingActivity string,
	batchId_INSERT string,
	batchId_UPDATE string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/RAP_factGamingActivity/2016';





--Endx Tables
--Select *  from retaildb.endxvisits limit 100; 
--Select *  from retaildb.region limit 100; 
--Select *  from retaildb.endxRTP limit 100; 

--Select *  from retaildb.endxpltransactions order by  TrnSessionDate limit 1000; -- where trnMember ='1730038961'

--Bally Tables
--Select *  from retaildb.ballyrtp limit 100; 
--Select *  from retaildb.ballyttablerating  limit 100; --Select *  from retaildb.ballyRTP limit 100; 
--Select *  from retaildb.ballytslotrating  limit 100;
--Select *  from retaildb.ballytpokerrating  limit 100; 

--Select * from retaildb.ballytdrop limit 100;
--select * from retaildb.rap_factgamingactivity limit 100;