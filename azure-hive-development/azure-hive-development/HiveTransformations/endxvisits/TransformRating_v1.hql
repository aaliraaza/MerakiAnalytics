--Sanity Check--Rating 
DROP TABLE IF EXISTS ballyttablerating_SC;
CREATE TABLE ballyttablerating_SC as 
SELECT  
    GroupKeyDate, GroupKeySource, TranID, PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID,
    GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, RatingPeriodMinutes, Plays, Bet, PaidOut ,
    TheorHoldPc, TheorWin, BasePts, BonusPts, BaseStubs, BonusStubs, EarnedAltComp, CasinoWinCalcMethod,
    CasinoWin, AddToPartialPts, CashBuyIn, CreditBuyIn, ChipBuyIn, TranCode, ModifiedDtm 
from retaildb.ballyttablerating
group by 
    GroupKeyDate, GroupKeySource, TranID, PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID,
    GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, RatingPeriodMinutes, Plays, Bet, PaidOut ,
    TheorHoldPc, TheorWin, BasePts, BonusPts, BaseStubs, BonusStubs, EarnedAltComp, CasinoWinCalcMethod,
    CasinoWin, AddToPartialPts, CashBuyIn, CreditBuyIn, ChipBuyIn, TranCode, ModifiedDtm;
--select count(*) from ballyttablerating_SC  limit 100;
--select count(*) from retaildb.ballyttablerating  limit 100;

--tTable Rating Transformations
DROP TABLE IF EXISTS trsrating;
CREATE TABLE trsrating as 
SELECT  
    a.PLAYERID,
	from_utc_timestamp(UNIX_TIMESTAMP(a.GamingDt, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as GamingDt,
	from_utc_timestamp(UNIX_TIMESTAMP(a.RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as RATINGSTARTDTM,
	from_utc_timestamp(UNIX_TIMESTAMP(a.RATINGENDDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as RATINGENDDTM,
    a.RatingPeriodMinutes,
	a.CasinoID,
	a.DeptID,
	a.GameID,
	a.BET, 
    b.rtp, 
    a.BET*b.rtp as Theowin
from ballyttablerating_SC as a
left join retaildb.ballyrtp2 as b on a.gameid=b.gameid;
--Select *  from trsrating limit 100; 



--Sanity Check--Slot 
DROP TABLE IF EXISTS ballytslotrating_SC;
CREATE TABLE ballytslotrating_SC as 
SELECT  groupDate, TranID, PlayerId, IsVoid, TranCodeID, 
		GamingDt, PostDtm, DeptID, CasinoID, 
		GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, 
		RatingPeriodMinutes, Plays, Bet, PaidOut, 
		TheorHoldPc, TheorWin, BasePts, BonusPts, 
		BaseStubs, BonusStubs, EarnedAltComp, CasinoWinCalcMethod, 
		CasinoWin, JackPot, AddToPartialPts, ModifiedDtm, CashBuyIn
from retaildb.ballytslotrating
group by groupDate, TranID, PlayerId, IsVoid, TranCodeID, 
		GamingDt, PostDtm, DeptID, CasinoID, 
		GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, 
		RatingPeriodMinutes, Plays, Bet, PaidOut, 
		TheorHoldPc, TheorWin, BasePts, BonusPts, 
		BaseStubs, BonusStubs, EarnedAltComp, CasinoWinCalcMethod, 
		CasinoWin, JackPot, AddToPartialPts, ModifiedDtm, CashBuyIn;
--select count(*) from ballytslotrating_SC  limit 100;
--select count(*) from retaildb.ballytslotrating  limit 100;

--tTable Slot Transformations
DROP TABLE IF EXISTS trsslot;
CREATE TABLE trsslot as 
SELECT  
    a.PLAYERID,
	from_utc_timestamp(UNIX_TIMESTAMP(a.GamingDt, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as GamingDt,
	from_utc_timestamp(UNIX_TIMESTAMP(a.RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as RATINGSTARTDTM,
	from_utc_timestamp(UNIX_TIMESTAMP(a.RATINGENDDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as RATINGENDDTM,
    a.RatingPeriodMinutes,
	a.CasinoID,
	a.DeptID,
	a.GameID,
	a.Bet, 
    b.rtp, 
    a.Bet*b.rtp as Theowin
from ballytslotrating_SC as a
left join retaildb.ballyrtp2 as b on a.gameid=b.gameid;
--Select *  from trsslot limit 100; 



--Sanity Check--Pocker 
DROP TABLE IF EXISTS ballytpokerrating_SC;
CREATE TABLE ballytpokerrating_SC as 
SELECT  groupDate, TranID,PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID, 
		GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, CashBuyIn, CreditBuyIn, 
		ChipBuyIn, PromoBuyIn, ECreditBuyIn, RatingPeriodMinutes, Plays, Bet, PaidOut, 
		TheorHoldPc, TheorWin, GamePts, BasePts, BonusPts, EarnedComp, BaseStubs, BonusStubs, 
		EarnedAltComp, Promo1, BonusPromo1, Promo2, BonusPromo2, CasinoWinCalcMethod, CasinoWin, 
		MgmtRating, LocnMinBet, LocnMaxBet, CasinoStatistic, PartialPt1, CreatedDtm, CreatedBy, 
		ModifiedDtm, ModifiedBy, AddToPartialPts, AddToPartialPts2, AddToPartialStubs, 
		AddToPartialStubs2, OldRelatedTranID, QualPts, SeatNo, FreqId, AdjBet, 
		AdjPaidOut, AdjTheorWin, AdjCasinoWin
from retaildb.ballytpokerrating
group by groupDate, TranID,PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID, 
		GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, CashBuyIn, CreditBuyIn, 
		ChipBuyIn, PromoBuyIn, ECreditBuyIn, RatingPeriodMinutes, Plays, Bet, PaidOut, 
		TheorHoldPc, TheorWin, GamePts, BasePts, BonusPts, EarnedComp, BaseStubs, BonusStubs, 
		EarnedAltComp, Promo1, BonusPromo1, Promo2, BonusPromo2, CasinoWinCalcMethod, CasinoWin, 
		MgmtRating, LocnMinBet, LocnMaxBet, CasinoStatistic, PartialPt1, CreatedDtm, CreatedBy, 
		ModifiedDtm, ModifiedBy, AddToPartialPts, AddToPartialPts2, AddToPartialStubs, 
		AddToPartialStubs2, OldRelatedTranID, QualPts, SeatNo, FreqId, AdjBet, 
		AdjPaidOut, AdjTheorWin, AdjCasinoWin;
--select count(*) from ballytpokerrating_SC  limit 100;
--select count(*) from retaildb.ballytpokerrating  limit 100;

--tPocker Pocker Transformations
DROP TABLE IF EXISTS trsrpocker;
CREATE TABLE trsrpocker as 
SELECT  
    a.PLAYERID,
	from_utc_timestamp(UNIX_TIMESTAMP(a.GamingDt, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as GamingDt,
	from_utc_timestamp(UNIX_TIMESTAMP(a.RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as RATINGSTARTDTM,
	from_utc_timestamp(UNIX_TIMESTAMP(a.RATINGENDDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT') as RATINGENDDTM,
    a.RatingPeriodMinutes,
	a.CasinoID,
	a.DeptID,
	a.GameID,
	a.Bet, 
    b.rtp, 
    a.BET*b.rtp as Theowin
from ballytpokerrating_SC as a
left join retaildb.ballyrtp2 as b on a.gameid=b.gameid;
--Select *  from trsrpocker limit 100; 


--RATING TABLE: Merge tablerating, slot and pocker 
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings as
Select unioned.*  from 
(Select *  from trsrating a
union all
Select *  from trsslot b
union all
Select *  from trsrpocker c) unioned; 
--select * from ratings limit 1000;



DROP TABLE IF EXISTS trnsfratings;
CREATE TABLE trnsfratings as 
SELECT  
    PlayerId, 
    to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) RATINGSTARTDTM,
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
--select * from trnsfratings limit 1000; 

----------------------------------------------------------------------------------------------------------------------
--DWELL TIME per transaction  
DROP TABLE IF EXISTS trndwelltime;
CREATE TABLE trndwelltime as 
select 
    PlayerId,
    to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) AS RATINGSTARTDTM,
    --to_date(from_utc_timestamp(UNIX_TIMESTAMP(RATINGSTARTDTM, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")*1000,'GMT')) AS RATINGENDDTM,
    (unix_timestamp(RATINGENDDTM)-unix_timestamp(RATINGSTARTDTM))/60 AS DwellTime,
    CasinoID, 
    GameID
from ratings
where casinoID !='32' and RATINGPERIODMINUTES > 1 and (GameID='3' or GameID='4' or GameID='6' or GameID='10000463' or GameID='21' or GameID='39' or GameID='49' or GameID='51' or GameID='57' or GameID ='240' or GameID='270' or GameID='272');
--DeptId='TABL' ---------------------=>(GameID='2W' or GameID='3C' or GameID='6CP' or GameID='7C' or GameID='AR' or GameID='BJ' or GameID='CP' or GameID='CS' or GameID='DICE' or GameID ='LR' or GameID='PB' or GameID='PRKE')
--select * from trndwelltime limit 100; 


--Average Dwell Time per retail customer
DROP TABLE IF EXISTS gamedwelltime;
CREATE TABLE gamedwelltime as 
select 
    PlayerId, 
    RATINGSTARTDTM, 
    CasinoID, 
    GameID,
    avg(DwellTime) as PlayerDwellTime
from trndwelltime
group by playerid, RATINGSTARTDTM, CasinoID, GameID;
--select * from gamedwelltime limit 100; 


--Average Dwell Time 
DROP TABLE IF EXISTS playerdwelltime;
CREATE TABLE playerdwelltime as 
select 
    PlayerId, 
    RATINGSTARTDTM, 
    avg(DwellTime) as PlayerDwellTime
from gamedwelltime
group by playerid, RATINGSTARTDTM;












