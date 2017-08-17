set hive.execution.engine=tez;
create database if not exists rawdb;


DROP TABLE IF NOT EXISTS rawdb.RapFactGamingActivity;
CREATE EXTERNAL TABLE IF NOT EXISTS rawdb.RapFactGamingActivity
(
    groupkeydate_c STRING,
    groupkeysource STRING,
    customerKey STRING,
	gameCode STRING,
	venueCode STRING,
	sessionCode STRING,
	dayId_CAL INT,
	dayId_GAME INT,
	gamingActivityIdSource STRING,
	sourceSystemCode STRING,
	amountStake DOUBLE,
	amountFreeStake DOUBLE,
	amountPayout DOUBLE,
	playPointsBaseEarn DOUBLE,
	playPointsBonusEarn DOUBLE,
	datetimeGamingActivity STRING,
	batchId_INSERT INT,
	batchId_UPDATE INT
)
PARTITIONED BY (groupkeydate STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 'wasbs://raw@alidslaketest.blob.core.windows.net/RAP_factGamingActivity/';

MSCK REPAIR TABLE rawdb.RapFactGamingActivity;

SELECT * FROM rawdb.RapFactGamingActivity 
WHERE groupkeydate = '2016-01-01'
LIMIT 100;


SELECT 
	groupkeysource
	,sum(case when gamingactivityidsource is null then 1 else 0 end) as c_nulls 
	,sum(case when gamingactivityidsource is not null then 1 else 0 end) as c_not_nulls
FROM rawdb.rapfactgamingactivity 
where sourcesystemcode IN ('OPBT_MECC', 'OPBT_GROS') and (groupkeydate >= '2016-01-01' and groupkeydate <= '2016-06-30')
group by groupkeysource;
