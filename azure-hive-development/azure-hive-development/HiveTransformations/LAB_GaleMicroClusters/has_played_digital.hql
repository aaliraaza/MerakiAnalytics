
DROP TABLE IF EXISTS proj_galedb.hasPlayedDigital;
CREATE TABLE IF NOT EXISTS proj_galedb.hasPlayedDigital
(
    customergoldbrandid STRING,
    hasPlayedDigital INT
)
CLUSTERED BY (hasPlayedDigital) INTO 2 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/has_played_digital';




INSERT OVERWRITE TABLE proj_galedb.hasPlayedDigital
SELECT 
	dimcustomers.customergoldbrandid
	,CASE WHEN SUM(
	  	CASE WHEN playedDigital.customerkey IS NULL THEN 0 ELSE 1 END
	 ) > 0 THEN 1 ELSE 0 END AS hasPlayedDigital
from proj_galedb.dimcustomers
left join (
  select 
  	distinct customerkey
  from (
	SELECT customerkey
	FROM basedb.rapfactgamingactivitydigital
	WHERE actiontypecode = 'Stake'
	  AND basecurrencycode = 'GBP'
      AND rapfactgamingactivitydigital.groupkeydate >= date_sub(current_date, 365)

	UNION ALL

	SELECT
	  customerkey
	FROM basedb.rapfactgamingactivityopenbet
    WHERE rapfactgamingactivityopenbet.groupkeydate >= date_sub(current_date, 365)

  ) unionedDigitalActivity
) playedDigital
on playedDigital.customerkey = dimcustomers.customerkey
group by dimcustomers.customergoldbrandid;