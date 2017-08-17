
DROP TABLE IF EXISTS proj_galedb.digitalGameEntropy;
CREATE TABLE IF NOT EXISTS proj_galedb.digitalGameEntropy
(
    customergoldbrandid STRING,
    gameEntropyStakes DOUBLE,
    gameEntropyTheo DOUBLE
)
CLUSTERED BY (customergoldbrandid) INTO 6 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/digital_game_entropy';




WITH DigitalActivity
AS
(
  SELECT customergoldbrandid
  	,DigitalActivity.gamecode
  	,SUM(Stakes) as Stakes
  	,SUM(Stakes) * (1.0 - Max(rtp)) as Theo
  FROM (
	    SELECT 
  		    customerkey 
  		    ,amountbasecurrency AS Stakes
		    ,gamecode
	    FROM basedb.rapfactgamingactivitydigital
	    WHERE actiontypecode = 'Stake'
	      AND basecurrencycode = 'GBP'
          AND rapfactgamingactivitydigital.groupkeydate >= date_sub(current_date, 365)

	    UNION ALL

	    SELECT
	      customerkey
          ,amountstake as Stakes
  	      ,gamecode
	    FROM basedb.rapfactgamingactivityopenbet
        WHERE rapfactgamingactivityopenbet.groupkeydate >= date_sub(current_date, 365)
 
  ) DigitalActivity
  left join proj_galedb.dimcustomers on dimcustomers.customerkey = DigitalActivity.customerkey
  LEFT JOIN proj_galedb.dimGames on DigitalActivity.gamecode = dimGames.gamecode
  LEFT JOIN proj_galedb.digitalRTP on dimGames.gametypecode = digitalRTP.gametypecode
  group by dimcustomers.customergoldbrandid, DigitalActivity.gamecode
)
INSERT OVERWRITE TABLE proj_galedb.digitalGameEntropy
SELECT customergoldbrandid
    ,-100.0*sum(gameEntropyStakes) as gameEntropyStakes
	,-100.0*sum(gameEntropyTheo) as gameEntropyTheo
FROM (
	SELECT DigitalActivity.customergoldbrandid
		   ,DigitalActivity.gamecode
		   ,( sum(Stakes) / max(TotalStakes) ) * LN( ( sum(Stakes) / max(TotalStakes) )) as gameEntropyStakes
		   ,( sum(Theo)   / max(TotalTheo)   ) * LN( ( sum(Theo)   / max(TotalTheo)   )) as gameEntropyTheo
	FROM DigitalActivity
	LEFT JOIN (
	   SELECT customergoldbrandid
			,sum(Stakes) as TotalStakes
			,sum(Theo) as TotalTheo
	   FROM DigitalActivity
	   Group By customergoldbrandid
	) Total ON Total.customergoldbrandid = DigitalActivity.customergoldbrandid
    where DigitalActivity.customergoldbrandid != '-1'
	group by DigitalActivity.customergoldbrandid, DigitalActivity.gamecode
) t1
Group By customergoldbrandid;