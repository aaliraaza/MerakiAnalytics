
create database if not exists rawdb;


DROP TABLE IF EXISTS rawdb.RapFactGamingActivityDigital;
CREATE EXTERNAL TABLE IF NOT EXISTS rawdb.RapFactGamingActivityDigital
(
    groupkeydate_c STRING,
    groupkeysource STRING,
    datetimeGamingActivity STRING,
	modifiedDate STRING,
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
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/RAP_factGamingActivityDigital/';

MSCK REPAIR TABLE rawdb.RapFactGamingActivityDigital;

SELECT * FROM rawdb.RapFactGamingActivityDigital 
WHERE groupkeydate = '2016-06-01'
LIMIT 100;