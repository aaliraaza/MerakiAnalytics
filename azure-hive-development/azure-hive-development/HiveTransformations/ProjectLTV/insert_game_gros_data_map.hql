select 
   groupkeydate,customerkey,  regexp_replace(concat(concat(t2.gamegroupid,'_'),t1.actiontypecode),' |"','') as key,
   sum(amountbasecurrency) amountbasecurrency

from basedb.rapfactgamingactivitydigital t1 inner join proj_ltv.gamegroup t2 on t1.gamecode = t2.gamecode

where t1.groupkeydate = '2016-03-01'
      and t1.venuecode ='BEDE_GROS'

group by groupkeydate,customerkey,regexp_replace(concat(concat(t2.gamegroupid,'_'),t1.actiontypecode),' |"','');