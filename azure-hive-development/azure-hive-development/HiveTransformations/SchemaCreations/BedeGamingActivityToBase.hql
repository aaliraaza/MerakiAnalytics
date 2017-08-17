SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

CREATE TABLE IF NOT EXISTS digitaldb.BedeGamingActivityBase
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


INSERT OVERWRITE TABLE digitaldb.BedeGamingActivityBase PARTITION (GroupKeyDate)
select
	GroupKeyDate,
	GroupKeySource,
	EventDate,
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
	EffectCreatedAt,
	EffectAmount,
	BalanceBeforeAdjustments,
	BalanceBeforeWinnings,
	BalanceBeforeRingfence,
	BalanceAfterAdjustments,
	BalanceAfterWinnings,
	BalanceAfterRingfence
from (
	select *
	  	,ROW_NUMBER() OVER(PARTITION BY PlayerId, EventId ORDER BY groupkeysource DESC) AS row_id
	from digitaldb.BedeGamingActivityRaw t1
) t2
WHERE row_id = 1;


select * from digitaldb.BedeGamingActivityBase limit 100;