--Computing favourite club based on endx visits.. this will be replaced for 
--Neon data once we have it.
DROP TABLE IF EXISTS tmpendxclubcount;
CREATE TABLE tmpendxclubcount as 
select 
    VisitMember  
    ,VisitClub
    ,count(VisitClub) as cnt
from tmptable 
where VisitSession >= date_add(VisitSession, 100) and VisitSession <= max(visitsession)
group by  VisitMember, VisitClub;

select * from tmpendxclubcount limit 1000;

