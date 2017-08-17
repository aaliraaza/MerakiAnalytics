--Sanity Check
DROP TABLE IF EXISTS ballyttablerating_SC;
CREATE TABLE ballyttablerating_SC as 
SELECT  groupDate,TranID,PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID, 
		GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, CashBuyIn, CreditBuyIn, 
		ChipBuyIn, PromoBuyIn, ECreditBuyIn, RatingPeriodMinutes, Plays, Bet, PaidOut, 
		TheorHoldPc, TheorWin, GamePts, BasePts, BonusPts, EarnedComp, BaseStubs, BonusStubs, 
		EarnedAltComp, Promo1, BonusPromo1, Promo2, BonusPromo2, CasinoWinCalcMethod, CasinoWin, 
		MgmtRating, LocnMinBet, LocnMaxBet, CasinoStatistic, PartialPt1, CreatedDtm, CreatedBy, 
		ModifiedDtm, ModifiedBy, AddToPartialPts, AddToPartialPts2, AddToPartialStubs, 
		AddToPartialStubs2, OldRelatedTranID, QualPts, SeatNo, FreqId, AdjBet, 
		AdjPaidOut, AdjTheorWin, AdjCasinoWin
from retaildb.ballyttablerating
group by groupDate,TranID,PlayerId, IsVoid, TranCodeID, GamingDt, PostDtm, DeptID, CasinoID, 
		GameID, PlayerTypeID, RatingStartDtm, RatingEndDtm, CashBuyIn, CreditBuyIn, 
		ChipBuyIn, PromoBuyIn, ECreditBuyIn, RatingPeriodMinutes, Plays, Bet, PaidOut, 
		TheorHoldPc, TheorWin, GamePts, BasePts, BonusPts, EarnedComp, BaseStubs, BonusStubs, 
		EarnedAltComp, Promo1, BonusPromo1, Promo2, BonusPromo2, CasinoWinCalcMethod, CasinoWin, 
		MgmtRating, LocnMinBet, LocnMaxBet, CasinoStatistic, PartialPt1, CreatedDtm, CreatedBy, 
		ModifiedDtm, ModifiedBy, AddToPartialPts, AddToPartialPts2, AddToPartialStubs, 
		AddToPartialStubs2, OldRelatedTranID, QualPts, SeatNo, FreqId, AdjBet, 
		AdjPaidOut, AdjTheorWin, AdjCasinoWin;


--tTable Rating Transformations
DROP TABLE IF EXISTS trsrating;
CREATE TABLE trsrating as 
SELECT  
    a.PLAYERID,
	a.GamingDt,
	a.RATINGSTARTDTM,
	a.RATINGENDDTM,
	a.CasinoID,
	a.DeptID,
	a.GameID,
	a.BET, 
    b.rtp, 
    a.BET*b.rtp as Theowin
from retaildb.ballyttablerating as a
left join retaildb.ballyrtp2 as b on a.gameid=b.gameid;
select count(*) from trsrating;


--tTable Rating Transformations
DROP TABLE IF EXISTS trsrating_SC;
CREATE TABLE trsrating_SC as 
SELECT  
    a.PLAYERID,
	a.GamingDt,
	a.RATINGSTARTDTM,
	a.RATINGENDDTM,
	a.CasinoID,
	a.DeptID,
	a.GameID,
	a.BET, 
    b.rtp, 
    a.BET*b.rtp as Theowin
from ballyttablerating_SC as a
left join retaildb.ballyrtp2 as b on a.gameid=b.gameid;
select count(*) from trsrating_SC;

--Select *  from retaildb.ballyttablerating where bet > 100 limit 100; 
--Select *  from trsrating   where bet > 100 limit 100; 
