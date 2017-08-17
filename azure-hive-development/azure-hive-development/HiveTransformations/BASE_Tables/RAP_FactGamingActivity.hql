SET hive.execution.engine=tez; 
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;


create database if not exists basedb;

DROP TABLE IF EXISTS basedb.RapFactGamingActivity;
CREATE TABLE IF NOT EXISTS basedb.RapFactGamingActivity
(
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
	datetimeGamingActivity TIMESTAMP,
	batchId_INSERT INT,
	batchId_UPDATE INT
)
PARTITIONED BY (groupkeydate STRING)
CLUSTERED BY(sourcesystemcode, customerKey) SORTED BY(datetimeGamingActivity) INTO 5 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://base@rgdsadldev.blob.core.windows.net/RAP_FactGamingActivity/';

MSCK REPAIR TABLE rawdb.RapFactGamingActivity;


INSERT OVERWRITE TABLE basedb.RapFactGamingActivity PARTITION (GroupKeyDate)
select
	GroupKeySource,
    customerKey,
	gameCode,
	venueCode,
	sessionCode,
	dayId_CAL,
	dayId_GAME,
	gamingActivityIdSource,
	sourceSystemCode,
	amountStake,
	amountFreeStake,
	amountPayout,
	playPointsBaseEarn,
	playPointsBonusEarn,
	from_unixtime(unix_timestamp(datetimeGamingActivity, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")) as datetimeGamingActivity,
	batchId_INSERT,
	batchId_UPDATE,
	GroupKeyDate
from (
	select *
	  	,ROW_NUMBER() OVER(PARTITION BY groupkeydate, gamingactivityidsource ORDER BY batchId_UPDATE DESC) AS row_id
	from rawdb.RapFactGamingActivity t1
    -- use this for a partial refresh of the base layer of the last 14 days
    -- make sure to run the MSCK REPAIR TABLE command first to add all raw-partitions to the meta store
    -- where groupkeydate >=  date_sub(current_date, 14)
) t2
WHERE row_id = 1;

ANALYZE TABLE basedb.RapFactGamingActivity PARTITION(groupkeydate) COMPUTE STATISTICS;
ANALYZE TABLE basedb.RapFactGamingActivity PARTITION(groupkeydate) COMPUTE STATISTICS FOR COLUMNS;


select * from basedb.RapFactGamingActivity limit 100;


DROP VIEW IF EXISTS basedb.RapFactGamingActivityOpenbet;
CREATE VIEW IF NOT EXISTS basedb.RapFactGamingActivityOpenbet
AS
select
  customerKey,
  gameCode,
  venueCode,
  sessionCode,
  dayId_CAL,
  dayId_GAME,
  gamingActivityIdSource,
  sourceSystemCode,
  amountStake,
  amountFreeStake,
  amountPayout,
  playPointsBaseEarn,
  playPointsBonusEarn,
  datetimeGamingActivity,
  batchId_INSERT,
  batchId_UPDATE,
  groupkeydate
from basedb.RapFactGamingActivityfix t1
where sourcesystemcode IN ('OPBT_MECC', 'OPBT_GROS');

SELECT  * FROM basedb.RapFactGamingActivityOpenbet where groupkeydate = '2015-01-01' LIMIT 100;