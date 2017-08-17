SELECT a.venuecode,a.datetimegamingactivity,a.customerkey,a.devicetypecode,
       a.gamecode,b.gamegroupid,a.actiontypecode,
	   a.wallet,amountbasecurrency,a.basecurrencycode
FROM basedb.rapfactgamingactivitydigital a INNER JOIN proj_ltv.gamegroup b
ON   a.gamecode=b.gamecode
where groupkeydate >= '2016-04-01' and groupkeydate < '2016-07-01' 
     and venuecode=='BEDE_GROS' and  customerkey=21206800
LIMIT 100;