SELECT DISTINCT a.gamegroupid

FROM proj_ltv.gamegroup a, basedb.rapfactgamingactivitydigital b

WHERE   a.gamecode=b.gamecode and 
        b.groupkeydate >= '2016-03-01' and b.groupkeydate < '2017-01-10' 
        and b.venuecode=='BEDE_GROS';
