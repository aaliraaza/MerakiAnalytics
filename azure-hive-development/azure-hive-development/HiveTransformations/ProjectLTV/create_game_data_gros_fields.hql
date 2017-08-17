SELECT DISTINCT concat(concat(a.gamegroupid,'_'),c.actiontypecode)
FROM proj_ltv.gamegroup a, basedb.rapfactgamingactivitydigital b
CROSS JOIN proj_ltv.actiontype c
WHERE   a.gamecode=b.gamecode and 
        b.groupkeydate >= '2016-03-01' 
		and b.groupkeydate < '2017-01-10' 
        and b.venuecode=='BEDE_GROS';