CREATE TABLE IF NOT EXISTS proj_ltv.actiontype
( 
  actiontypecode    STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_Ltv/data/actiontype/';

INSERT OVERWRITE TABLE proj_ltv.actiontype
SELECT DISTINCT rapfactgamingactivitydigital.actiontypecode 
FROM basedb.rapfactgamingactivitydigital;