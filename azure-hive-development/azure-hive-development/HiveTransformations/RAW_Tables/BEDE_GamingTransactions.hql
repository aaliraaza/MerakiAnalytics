
create database if not exists rawdb;


DROP TABLE IF EXISTS rawdb.BedeGamingActivity;
CREATE EXTERNAL TABLE IF NOT EXISTS rawdb.BedeGamingActivity
(
	GroupKeyDate_c STRING,
    GroupKeySource STRING,
    EventDate STRING,
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
    EffectCreatedAt STRING,
    EffectAmount DOUBLE,
    BalanceBeforeAdjustments DOUBLE,
    BalanceBeforeWinnings DOUBLE,
    BalanceBeforeRingfence DOUBLE,
    BalanceAfterAdjustments DOUBLE,
    BalanceAfterWinnings DOUBLE,
    BalanceAfterRingfence DOUBLE
)
PARTITIONED BY (groupkeydate STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/BEDE_GamingTransactions/';

MSCK REPAIR TABLE rawdb.BedeGamingActivity;


SELECT * FROM rawdb.BedeGamingActivity
WHERE groupkeydate = '2016-06-01' LIMIT 100;