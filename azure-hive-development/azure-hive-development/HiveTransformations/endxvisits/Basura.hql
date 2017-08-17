select * from ratings;
select * from playerdwelltime limit 100; 
select * from playerdwelltime limit 100; 

--Ratings table 
DROP TABLE IF EXISTS Theos;
CREATE TABLE Theos as 
select 
    PLAYERID,
    to_date(from_utc_timestamp(UNIX_TIMESTAMP(GamingDt, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) AS GamingDt,	
	to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) AS RATINGSTARTDTM,	
    to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGENDDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) AS RATINGENDDTM,	
	CasinoID,
	DeptID,
	GameID,
	Bet, 
    Theowin,
    case when CasinoID != '555' then TheoWin else 0 end as RetailTheo,
    case when CasinoID = '555' then TheoWin else 0 end as DigitalTheo
from ratings;
--select * from Theos limit 1000;


DROP TABLE IF EXISTS Test;
CREATE TABLE Test as 
SELECT  
    PlayerId, 
    to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) RATINGENDDTM,
    --substr(RATINGENDDTM, 12) as RATINGSTARTDTM1,
	max(case when CasinoID !='32' then 1 
	else 0
	end) as Retail,
	max(case when CasinoID = '32' then 1 
	else 0 
	end) as Digital,
	sum(case when CasinoID !='32' then 1 
	else 0 end) as TrnRetail,
	sum(case when CasinoID ='32' then 1 
	else 0 end) as TrnDigital,
	sum(case when DeptID ='3' then 1 
	else 0 end) as DSLT,
	sum(case when DeptID = '4' then 1 
	else 0 end) as DTBL,
	sum(case when DeptID ='5' then 1 
	else 0 end) as F_B,
	sum(case when DeptID ='7' then 1 
	else 0 end) as MSLT,
	sum(case when DeptID = '8' then 1 
	else 0 end) as MTBL,
	sum(case when DeptID ='9' then 1 
	else 0 end) as OTHR	,			  
	sum(case when DeptID = '10' then 1 
	else 0 end) as POKR,
	sum(case when DeptID ='11' then 1 
	else 0 end) as SLOT	,			  
	sum(case when DeptID = '13' then 1 
	else 0 end) as TABL,
	sum(BET) as Bet,
    sum(case when hour(RATINGENDDTM) >= 0 and hour(RATINGENDDTM) < 6 then 1 else 0 end) as TheoA,
    sum(case when hour(RATINGENDDTM) >= 6 and hour(RATINGENDDTM) < 12 then 1 else 0 end) as TheoB,
    sum(case when hour(RATINGENDDTM) >= 12 and hour(RATINGENDDTM) < 18 then 1 else 0 end) as TheoC,
    sum(case when hour(RATINGENDDTM) >= 18 and hour(RATINGENDDTM) <= 23 then 1 else 0 end) as TheoD,
    sum(case when CasinoID != '32' then Theowin else 0 end) as RetailTheo,
    sum(case when CasinoID = '32' then Theowin else 0 end) as DigitalTheo
from ratings
group by PlayerId, to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')); 
--> Casinocode=555'=> CasinoID != '32'
select * from Test limit 1000;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ``````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  


DROP TABLE IF EXISTS test;
CREATE TABLE test as 
SELECT 
        PLAYERID,
		RATINGSTARTDTM,
		--GAMINGDT,
		Retail,
		Digital,
        RetailTheo,
        DigitalTheo,
       --RetailTheo/(DigitalTheo+DigitalTheo),
        (cast(DigitalTheo as float)/(cast(RetailTheo as float)+cast(DigitalTheo as float)))*100.0 as Digitalpercentage, 
        (cast(DigitalTheo as double)/(cast(RetailTheo as double)+cast(DigitalTheo as double)))*100.0 as DigitalpercentageT,
         cast(DigitalTheo/(RetailTheo+DigitalTheo)*100.0 as double) as DigitalpercentageT2
from trnsfratings;



	




--------------------------------
--LEFT JOIN: Dual Time
DROP TABLE IF EXISTS ratingsD;
CREATE TABLE ratingsD as 
SELECT 
    a.*,
    b.PlayerDwellTime
from ratings as a
left join gamedwelltime as b on a.playerid=b.playerid, a.RATINGSTARTDTM =b.RATINGSTARTDTM, a.CasinoID=b.CasinoId, a.GameID = b.GameId;
------------------------------------------------------

DROP TABLE IF EXISTS Test;
CREATE TABLE Test as 
SELECT  
    TranID, PlayerId, from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as ModifiedDtm, count(*) as test
from retaildb.ballyttablerating 
group by TranID, PlayerId, ModifiedDtm
order by TranID, PlayerId, ModifiedDtm;


select * from test where test>1 limit 1000; 
select * from retaildb.ballyttablerating  limit 1000;


--------------------------------------------------------------------------
DROP TABLE IF EXISTS keytablerating;
CREATE TABLE keytablerating as 
SELECT  
    TranID, 
    PlayerId, 
    Max(from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) as ModifiedDtm, 
    count(*) as test
from retaildb.ballyttablerating 
group by TranID, PlayerId, ModifiedDtm
order by TranID, PlayerId, ModifiedDtm;
--select * from keytablerating limit 1000;  


--Sanity Check--Rating 
DROP TABLE IF EXISTS ballyttablerating_SC;
CREATE TABLE ballyttablerating_SC as 
SELECT  b.*
from keytablerating as a
left join retaildb.ballyttablerating  as b on a.TranID=b.TranID and a.ModifiedDtm = from_utc_timestamp(UNIX_TIMESTAMP(b.ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') and  a.PlayerId=b.PlayerId;



DROP TABLE IF EXISTS keyslotrating;
CREATE TABLE keyslotrating as 
SELECT  
    TranID, 
    PlayerId, 
    Max(from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) as ModifiedDtm, 
    count(*) as test1
from retaildb.ballytslotrating 
group by TranID, PlayerId, ModifiedDtm
order by TranID, PlayerId, ModifiedDtm;
--select count(*) from ballyttablerating_SC  limit 100;
--select count(*) from retaildb.ballyttablerating  limit 100;
select * from keyslotrating limit 1000;  


DROP TABLE IF EXISTS keypokerrating;
CREATE TABLE keypokerrating as 
SELECT  
    TranID, 
    PlayerId, 
    Max(from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) as ModifiedDtm, 
    count(*) as test2
from retaildb.ballytpokerrating 
group by TranID, PlayerId, ModifiedDtm
order by TranID, PlayerId, ModifiedDtm;
--select count(*) from ballyttablerating_SC  limit 100;
--select count(*) from retaildb.ballyttablerating  limit 100;

select * from keypokerrating limit 1000;  

---------------------------------------------------------------------------------
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



DROP TABLE IF EXISTS Test;
CREATE TABLE Test as 
SELECT  
    TranID, PlayerId, from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as ModifiedDtm, count(*) as test
from retaildb.ballyttablerating 
group by TranID, PlayerId, ModifiedDtm
order by TranID, PlayerId, ModifiedDtm;


select * from test where test>1 limit 1000; 
select * from retaildb.ballyttablerating  limit 1000;
--select * from retaildb.ballytslotrating  limit 1000;
--select * from retaildb.ballytpokerrating  limit 1000;

--------------------------------------------------------------------------------------------------------------------------------------------------------
groupDate date,
    GroupKey string,
	TranID  string,
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
    CashBuyIn string, 
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

------------------------------------------------------------------------
DROP TABLE IF EXISTS trnsfratings;
CREATE TABLE trnsfratings as 
select 
    PLAYERID,
	unix_timestamp(RATINGENDDTM) AS RATINGSTARTDTM,
    RATINGSTARTDTM,
    --to_date(from_utc_timestamp(UNIX_TIMESTAMP(GamingDt, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) AS GamingDt,
    (CASE when cast(RATINGSTARTDTM as timestamp) >= '00:00:00.000' and cast(RATINGSTARTDTM as timestamp) < '06:00:00.000' then TheoWin else 0.0 end) AS TheoA,
	(CASE when cast(RATINGSTARTDTM as timestamp) >= '06:00:00.000' and cast(RATINGSTARTDTM as timestamp) < '12:00:00.000' then TheoWin else 0.0 end) AS TheoB,
	(CASE when cast(RATINGSTARTDTM as timestamp) >= '12:00:00.000' and cast(RATINGSTARTDTM as timestamp) < '18:00:00.000' then TheoWin else 0.0 end) AS TheoC,
	(CASE when cast(RATINGSTARTDTM as timestamp) >= '18:00:00.000' and cast(RATINGSTARTDTM as timestamp) <= '23:59:59.999' then TheoWin else 0.0 end) AS TheoD,
	(TheoWin) AS TotalTheoWin
FROM ratings;
--group by PLAYERID, GAMINGDT	  
--order by PLAYERID, GAMINGDT



SELECT  
    TranID, PlayerId, from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as ModifiedDtm
from retaildb.ballyttablerating 
where tranID='140375943'
order by tranID; 
--group by TranID, PlayerId, ModifiedDtm
--order by TranID, PlayerId, ModifiedDtm;


--select * from test where test>1 limit 1000; 
--select * from retaildb.ballyttablerating  limit 1000;


--Sanity Check--Rating 
DROP TABLE IF EXISTS ballyttablerating_SC;
CREATE TABLE ballyttablerating_SC as 
SELECT  
     b.*
from keytablerating as a
left join retaildb.ballyttablerating  as b on a.TranID=b.TranID and a.PlayerId=b.PlayerId;

select * from keytablerating;
select * from ballyttablerating_SC;
select count(*) from retaildb.ballyttablerating;



--Sanity Check--Rating 
SET hive.support.sql11.reserved.keywords=false;
DROP TABLE IF EXISTS ballyttablerating_SC;
CREATE TABLE ballyttablerating_SC as 
SELECT  
    ROW_NUMBER() OVER(PARTITION BY TranID, PlayerId, from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')  ORDER BY from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')  DESC) AS Row,
    GroupKeyDate, GroupKeySource, TranID, PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID,
    GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, RatingPeriodMinutes, Plays, Bet, PaidOut ,
    TheorHoldPc, TheorWin, BasePts, BonusPts, BaseStubs, BonusStubs, EarnedAltComp, CasinoWinCalcMethod,
    CasinoWin, AddToPartialPts, CashBuyIn, CreditBuyIn, ChipBuyIn, TranCode, from_utc_timestamp(UNIX_TIMESTAMP(ModifiedDtm, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')  
from retaildb.ballyttablerating
WHERE Row==1;
