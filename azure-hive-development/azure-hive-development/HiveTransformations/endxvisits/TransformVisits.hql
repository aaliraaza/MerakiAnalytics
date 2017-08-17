DROP TABLE IF EXISTS temptable;
CREATE TABLE temptable as 
select 
visitmember,
visitclub,
to_date(from_utc_timestamp(UNIX_TIMESTAMP(VisitSession, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) as VisitSessionDate,
from_utc_timestamp(UNIX_TIMESTAMP(visittime, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as VisitTimeStamp
from retaildb.endxvisits;


--Computing favourite club based on endx visits.. this will be replaced for 
--Neon data once we have it.
DROP TABLE IF EXISTS tempendxclubcount;
CREATE TABLE tempendxclubcount as 
select 
    a.visitmember  
    ,a.visitclub
    ,count(a.visitclub) as cnt
from temptable as a
---CHANGE DATE RANGE TO FULL RANGE SO WE CAPTURE EVERY CUSTOMER!! 
where a.VisitSessionDate >= date_add('2016-01-01', -200) and a.VisitSessionDate <= '2016-01-01'
group by  a.visitmember, a.visitclub;


--Favourite club
DROP TABLE IF EXISTS favoclub;
CREATE TABLE favoclub as 
SELECT a.visitmember, a.cnt, a.visitclub
FROM tempendxclubcount as a
INNER JOIN (
	SELECT VisitMember, MAX(cnt) as  cnt
	FROM tempendxclubcount
	GROUP BY visitmember
) b ON a.visitmember = b.visitmember AND a.cnt = b.cnt;


--remove any ties in counts per member by just selecting the max(club)
DROP TABLE IF EXISTS favoclubfinal;
CREATE TABLE favoclubfinal as 
SELECT
visitmember,
max(visitclub) as FavClub
FROM favoclub
GROUP BY visitmember;
--select count(DISTINCT visitmember) from favoclubfinal;


--Visits Table
DROP TABLE IF EXISTS visit;
CREATE TABLE visit as 
SELECT
     visitmember
    ,VisitSessionDate
    ,from_unixtime(unix_timestamp(VisitSessionDate,'yyyy-MM-dd'),'E') as DayOfTheWeek
    ,from_unixtime(unix_timestamp(VisitSessionDate,'yyyy-MM-dd'),'M') as Month          
    ,sum(case 
    when hour(VisitTimeStamp) >= 0 and hour(VisitTimeStamp) < 6 then 1
    else 0
    end) as A,
    sum(case 
    when hour(VisitTimeStamp) >= 6 and hour(VisitTimeStamp) < 12 then 1
    else 0
    end) as B,
    sum(case
    when hour(VisitTimeStamp) >= 12 and hour(VisitTimeStamp) < 18 then 1
    else 0
    end) as C,
    sum(case
    when hour(VisitTimeStamp) >= 18 and hour(VisitTimeStamp) <= 23 then 1
    else 0
    end) as D 
    ,count(*) as ClubCounts 
  from temptable
  group by visitmember,VisitSessionDate, from_unixtime(unix_timestamp(VisitSessionDate,'yyyy-MM-dd'),'E'),
            from_unixtime(unix_timestamp(VisitSessionDate,'yyyy-MM-dd'),'M');
--select count(DISTINCT visitmember) from visit;


--Megin tables
DROP TABLE IF EXISTS visitsfin;
CREATE TABLE visitsfin as 
SELECT
    a.visitmember
   ,a.VisitSessionDate
   ,a.DayOfTheWeek
   ,a.Month
   ,a.A
   ,a.B
   ,a.C
   ,a.D
   ,a.ClubCounts
   ,b.FavClub
  -- ,c.Club
   ,c.Region
    from visit  a
    LEFT JOIN favoclubfinal b on a.visitmember = b.visitmember
    LEFT JOIN retaildb.region c on b.FavClub=c.EndxNumber;
--NB: Need to be include the Gender and the FirstRegistrationDate


--DROP FROM ENDX
--SANITY CHECK TO ELIMINTE DUPLICATES IN endxpltransactions
DROP TABLE IF EXISTS playertrnSNT;
CREATE TABLE playertrnSNT as 
SELECT
  	groupDate,
    ---GroupKey,
	TrnNumber, 
	TrnSessionDate, 
	TrnClub, 
	TrnMember, 
	TrnTableType ,
	TrnDrop, 
	TrnWinLoss,
	TrnTimeStamp, 
	TrnCashOut, 
    TrnPokerSpend
FROM retaildb.endxpltransactions
group by groupDate, TrnNumber, TrnSessionDate, TrnClub, TrnMember, TrnTableType ,TrnDrop, TrnWinLoss,TrnTimeStamp, TrnCashOut, TrnPokerSpend;


--Drop and Thewin from Endx
DROP TABLE IF EXISTS endxplayertransactions;
CREATE TABLE endxplayertransactions as 
SELECT 
  a.TrnMember
, to_date(from_utc_timestamp(UNIX_TIMESTAMP(a.TrnSessionDate, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) as TrnSessionDate 
, a.TrnDrop
, a.TrnWinLoss
, a.TrnTableType 
--, CASE WHEN TrnTableType!='NULL' THEN a.TrnDrop*b.rtp ELSE a.TrnDrop*
, COALESCE(b.rtp, CAST(0.117 AS float)) as rtp2
, b.rtp
, a.TrnDrop*b.rtp as EndxTheoWin
   FROM playertrnSNT as a
LEFT JOIN retaildb.endxRTP as b on a.TrnTableType = b.trntabletype;


--Aggregate Drop table by customer and trnDate
DROP TABLE IF EXISTS playertransactions;
CREATE TABLE playertransactions as 
SELECT 
    TrnMember,
	TrnSessionDate,
    sum(TrnDrop) as TotalDrop,
	sum(TrnWinLoss) as TrnWinLoss,
	sum(EndxTheoWin) as EndxTheoWin
from endxplayertransactions
group by TrnMember, TrnSessionDate;
--order by Member, SessionDateModify 


--Final table 
DROP TABLE IF EXISTS EnxTable;
CREATE TABLE EnxTable as 
SELECT  
    a.*, 
    COALESCE(b.TotalDrop, CAST(0 AS BIGINT)) as TotalDrop, 
    COALESCE(b.TrnWinLoss, CAST(0 AS BIGINT)) as TrnWinLoss, 
    COALESCE(b.EndxTheoWin, CAST(0 AS BIGINT)) as EndxTheoWin
from visitsfin as a
left join playertransactions as b
			 on a.VisitMember = b.TrnMember and a.VisitSessionDate = b.TrnSessionDate;
--order by a.VisitMember, a.VisitSessionFormatted


--CHECKINGS
--select count(*) as cnt2 from visitsfin;
--select count(*) as cnt3 from visitsfina;
--select * from temptable order by VisitSessionDate limit 100;
select * from visitsfin order by VisitSessionDate limit 100;
--select * from visitsfina order by VisitSessionDate limit 100;
--select * from retaildb.endxpltransactions order by TrnSessionDate limit 100;
--select * from playertrnSNT where TrnTableType ='2' order by  TrnSessionDate limit 100;
select * from endxplayertransactions order by trnsessiondate limit 100;
select * from playertransactions order by trnsessiondate limit 1000; 
select * from EnxTable order by VisitSessionDate limit 1000;