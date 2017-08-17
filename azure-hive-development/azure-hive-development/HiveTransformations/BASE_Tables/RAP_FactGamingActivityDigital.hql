SET hive.execution.engine=tez; 
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;


create database if not exists basedb;

DROP TABLE IF EXISTS basedb.RapFactGamingActivityDigital;
CREATE TABLE IF NOT EXISTS basedb.RapFactGamingActivityDigital
(
    groupkeysource STRING,
    datetimeGamingActivity TIMESTAMP,
	modifiedDate TIMESTAMP,
	sessionCode STRING,
	dayID_CAL INT,
	dayID_GAME INT,
	eventIDSource BIGINT,
	actionIDSource BIGINT,
	eventIDGameProvider BIGINT,
	actionIDGameProvider BIGINT,
	actionTypeCode STRING,
	customerKey BIGINT,
	gameCode STRING,
	wallet STRING,
	walletTypeCode STRING,
	amountBaseCurrency DOUBLE,
	baseCurrencyCode STRING,
	venueCode STRING,
	sourceSystemCode STRING,
	batchId_INSERT INT,
	batchId_UPDATE STRING,
	deviceTypeCode STRING
)
PARTITIONED BY (groupkeydate STRING)
CLUSTERED BY(customerKey) SORTED BY(datetimeGamingActivity) INTO 10 BUCKETS 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://base@rgdsadldev.blob.core.windows.net/RAP_FactGamingActivityDigital/';


MSCK REPAIR TABLE rawdb.RapFactGamingActivityDigital;


INSERT OVERWRITE TABLE basedb.RapFactGamingActivityDigital PARTITION (GroupKeyDate)
select
	GroupKeySource,
	from_unixtime(unix_timestamp(datetimeGamingActivity, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")) as datetimeGamingActivity,
	from_unixtime(unix_timestamp(modifiedDate, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")) as modifiedDate,
    sessionCode,
	dayID_CAL,
	dayID_GAME,
	eventIDSource,
	actionIDSource,
	eventIDGameProvider,
	actionIDGameProvider,
	actionTypeCode,
	customerKey,
	gameCode,
	wallet,
	walletTypeCode,
	amountBaseCurrency,
	baseCurrencyCode,
	venueCode,
	sourceSystemCode,
	batchId_INSERT,
	batchId_UPDATE,
	deviceTypeCode,
	GroupKeyDate_c
from (
	select *
	  	,ROW_NUMBER() OVER(PARTITION BY customerKey, actionIDSource ORDER BY unix_timestamp(modifiedDate, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'") DESC) AS row_id
	from rawdb.RapFactGamingActivityDigital t1
    -- use this for a partial refresh of the base layer of the last 14 days
    -- make sure to run the MSCK REPAIR TABLE command first to add all raw-partitions to the meta store
    -- where groupkeydate >=  date_sub(current_date, 14)
) t2
WHERE row_id = 1;


select * from basedb.RapFactGamingActivityDigital limit 100;
