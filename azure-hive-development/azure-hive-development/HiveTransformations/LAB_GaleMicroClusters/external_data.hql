SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;


DROP TABLE IF EXISTS proj_galedb.opbt_gamecoding;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.opbt_gamecoding
(
   Brand STRING,
   GroupCategory STRING,
    Category STRING,
	Platform STRING,
	Supplier STRING,
	Game_Name STRING,
	ABSCode STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/opbt_game_coding'
tblproperties ("skip.header.line.count"="1");



-- DimGames
DROP TABLE IF EXISTS proj_galedb.dimGames;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.dimGames(
  gameCode STRING,
  gameName STRING,
  gameProviderCode STRING,
  gameGroupCode STRING,
  gameTypeCode STRING,
  dataSourceCode STRING,
  gameCode_SOURCE STRING,
  batchId_INSERT STRING,
  batchId_UPDATE STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/dimGames'
tblproperties ("skip.header.line.count"="1");


ANALYZE TABLE proj_galedb.dimGames COMPUTE STATISTICS;
ANALYZE TABLE proj_galedb.dimGames COMPUTE STATISTICS FOR COLUMNS;


-- sem_dimCustomer
DROP TABLE IF EXISTS proj_galedb.semdimCustomers;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.semdimCustomers(
    customerKey_RAW STRING,
    customerKey STRING,
    customerKey_INT STRING,
    customerBrand STRING,
    gender STRING,
    YearOfBirth_INT STRING,
    YearOfBirth STRING,
    isBarredRetail STRING,
    isBarredOnline STRING,
    IsSelfExclude STRING,
    CRMEmailOptInRetail STRING,
    CRMEmailOptInOnline STRING,
    CRMPostalOptInRetail STRING,
    CRMPostalOptInOnline STRING,
    CRMSMSOptInRetail STRING,
    CRMSMSOptInOnline STRING,
    CRMTelephoneOptInRetail STRING,
    CRMTelephoneOptInOnline STRING,
    IsVIPRetail STRING,
    VIPLevelRetail STRING,
    IsVIPOnline STRING,
    VIPLevelOnline STRING
)
SKEWED BY (customerBrand) ON ('Grosvenor')
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/sem_dimCustomer'
tblproperties ("skip.header.line.count"="1");

ANALYZE TABLE proj_galedb.semdimCustomers COMPUTE STATISTICS;
ANALYZE TABLE proj_galedb.semdimCustomers COMPUTE STATISTICS FOR COLUMNS;


-- dimCustomer
DROP TABLE IF EXISTS proj_galedb.dimCustomersRaw;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.dimCustomersRaw(
    customerKey STRING,
    customerId_SOURCE STRING,
    sourceSystemCode STRING,
    customerGoldId_BV STRING,
    customerGoldBrandId STRING,
    batchId_INSERT STRING,
    batchId_UPDATE STRING,
    customerGoldId STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/dimCustomer'
tblproperties ("skip.header.line.count"="1");

ANALYZE TABLE proj_galedb.dimCustomersRaw COMPUTE STATISTICS;
ANALYZE TABLE proj_galedb.dimCustomersRaw COMPUTE STATISTICS FOR COLUMNS;


DROP TABLE IF EXISTS proj_galedb.dimCustomersDigital;
CREATE TABLE IF NOT EXISTS proj_galedb.dimCustomersDigital(
    customerKey STRING,
    customerId_SOURCE STRING,
    sourceSystemCode STRING,
    customerGoldId_BV STRING,
    customerGoldBrandId STRING,
    batchId_INSERT STRING,
    batchId_UPDATE STRING,
    customerGoldId STRING
)
CLUSTERED BY (customerGoldBrandId) INTO 6 BUCKETS
SKEWED BY (sourceSystemCode) ON ('OPBT_MECC', 'BEDE_MECC')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/data/dim_customer_digital';

INSERT OVERWRITE TABLE proj_galedb.dimCustomersDigital
SELECT
    *
FROM proj_galedb.dimCustomersRaw
Where sourceSystemCode in ('BEDE_MECC', 'BEDE_GROS', 'OPBT_MECC', 'OPBT_GROS');

ANALYZE TABLE proj_galedb.dimCustomersDigital COMPUTE STATISTICS;
ANALYZE TABLE proj_galedb.dimCustomersDigital COMPUTE STATISTICS FOR COLUMNS;

DROP TABLE IF EXISTS proj_galedb.dimCustomers;
CREATE TABLE IF NOT EXISTS proj_galedb.dimCustomers(
    customerKey STRING,
    customerId_SOURCE STRING,
    sourceSystemCode STRING,
    customerGoldId_BV STRING,
    customerGoldBrandId STRING,
    batchId_INSERT STRING,
    batchId_UPDATE STRING,
    customerGoldId STRING
)
CLUSTERED BY (customerGoldBrandId) INTO 6 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/data/dim_customer';

INSERT OVERWRITE TABLE proj_galedb.dimCustomers
SELECT
    *
FROM proj_galedb.dimCustomersRaw;

ANALYZE TABLE proj_galedb.dimCustomers COMPUTE STATISTICS;
ANALYZE TABLE proj_galedb.dimCustomers COMPUTE STATISTICS FOR COLUMNS;



-- dimCustomerAttribues
DROP TABLE IF EXISTS proj_galedb.dimCustomerAttributes;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.dimCustomerAttributes(
   customerKey STRING,
   sourceUpdateDate STRING,
   registrationDate  STRING,
   acquisitionChannel STRING,
   acquisitionGroup STRING,
   gender STRING,
   yearOfBirth STRING,
   postCodeSector STRING,
   isBarred STRING,
   dateBarredFrom STRING,
   dateBarredTo STRING,
   isSelfExclude STRING,
   dateSelfExcludeFrom STRING,
   dateSelfExcludedTo STRING,
   customerAccount STRING,
   isCRMPostal STRING,
   isCRMTelephone STRING,
   isCRMSMS  STRING,
   isCRMEmail  STRING,
   dateCRMPostal STRING,
   dateCRMEmail STRING,
   dateCRMTelephone  STRING,
   dateCRMSMS  STRING,
   batchId_INSERT  STRING,
   batchId_UPDATE STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/dimCustomerAttribute'
tblproperties ("skip.header.line.count"="1");

ANALYZE TABLE proj_galedb.dimCustomerAttributes COMPUTE STATISTICS;
ANALYZE TABLE proj_galedb.dimCustomerAttributes COMPUTE STATISTICS FOR COLUMNS;



