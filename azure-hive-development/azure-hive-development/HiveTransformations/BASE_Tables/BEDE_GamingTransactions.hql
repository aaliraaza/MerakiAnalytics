SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;


create database if not exists basedb;

DROP TABLE IF EXISTS basedb.BedeGamingActivity;
CREATE TABLE IF NOT EXISTS basedb.BedeGamingActivity
(
    GroupKeySource STRING,
    EventDate TIMESTAMP,
    PlayerId BIGINT,
    GameId BIGINT,
    Channel STRING,
    EventId BIGINT,
    ProviderEventId BIGINT,
    ActionId BIGINT,
    ProviderActionId BIGINT,
    ActionType STRING,
    CurrencyCode STRING,
    WalletName STRING,
    WalletType STRING,
    WalletCompartment STRING,
    EffectCreatedAt TIMESTAMP,
    EffectAmount DOUBLE,
    BalanceBeforeAdjustments DOUBLE,
    BalanceBeforeWinnings DOUBLE,
    BalanceBeforeRingfence DOUBLE,
    BalanceAfterAdjustments DOUBLE,
    BalanceAfterWinnings DOUBLE,
    BalanceAfterRingfence DOUBLE
)
PARTITIONED BY (GroupKeyDate STRING)
CLUSTERED BY(PlayerId) SORTED BY(EventDate) INTO 10 BUCKETS 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://base@rgdsadldev.blob.core.windows.net/BEDE_GamingTransactions/';


MSCK REPAIR TABLE rawdb.BedeGamingActivity;


INSERT OVERWRITE TABLE basedb.BedeGamingActivity PARTITION (GroupKeyDate)
select
	GroupKeySource,
	from_unixtime(unix_timestamp(EventDate, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")) as EventDate,
	PlayerId,
	GameId,
	Channel,
	EventId,
	ProviderEventId,
	ActionId,
	ProviderActionId,
	ActionType,
	CurrencyCode,
	WalletName,
	WalletType,
	WalletCompartment,
	from_unixtime(unix_timestamp(EffectCreatedAt, "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'")) as EffectCreatedAt,
	EffectAmount,
	BalanceBeforeAdjustments,
	BalanceBeforeWinnings,
	BalanceBeforeRingfence,
	BalanceAfterAdjustments,
	BalanceAfterWinnings,
	BalanceAfterRingfence,
	GroupKeyDate
from (
	select *
	  	,ROW_NUMBER() OVER(PARTITION BY PlayerId, EventId ORDER BY groupkeysource DESC) AS row_id
	from rawdb.BedeGamingActivity t1
    -- use this for a partial refresh of the base layer of the last 14 days
    -- make sure to run the MSCK REPAIR TABLE command first to add all raw-partitions to the meta store
    -- where groupkeydate >=  date_sub(current_date, 14)
) t2
WHERE row_id = 1;


select * from basedb.BedeGamingActivity limit 100;
