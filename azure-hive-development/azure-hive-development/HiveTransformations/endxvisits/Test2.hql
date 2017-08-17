--Select *  from trsrating limit 100; 
--Select *  from trsslot limit 100; 
--Select *  from trsrpocker limit 100; 
--select * from ratings;

--Select count(*)  from trsrating;--9,233,644
--Select count(*)  from trsslot;--14,954,450
--Select count(*)  from trsrpocker;--564,661
--select count(*) from rating; --24,752,755

--select * from trndwelltime limit 100; 
--select * from gamedwelltime limit 100;

--select * from trnsfratings limit 1000; 
--select * from trnsfratings where playerid='1000831' and RATINGSTARTDTM ='2016-10-02'limit 1000;  


--select * from retaildb.ballyttablerating limit 1000;
--select count(*) from retaildb.ballyttablerating;


--select * from keytablerating limit 1000; 
--select count(*) from keytablerating; 

--select * from trndwelltime where PlayerId='1000231' and RATINGSTARTDTM ='2016-02-11' limit 100; 
--select * from gamedwelltime where PlayerId='1000231' and RATINGSTARTDTM ='2016-02-11' limit 100; 
--select * from tabledwelltime where DwellTime <='0' order by RATINGSTARTDTM limit 100; 

--SET hive.support.sql11.reserved.keywords=false;
--Sanity Check--Rating 



--select * from gamedwelltime limit 100; 

--select * from trndwelltime where PlayerId='1000231' and RATINGSTARTDTM ='2016-02-11' limit 100; 
--select * from gamedwelltime where PlayerId='1000231' and RATINGSTARTDTM ='2016-02-11' limit 100; 
--select * from test where DwellTime <='0' order by RATINGSTARTDTM limit 1000; 

Select *  from retaildb.endxpltransactions order by  TrnSessionDate limit 1000;
select * from retaildb.ballytdrop limit 100;
select * from retaildb.rap_factgamingactivity limit 100;

