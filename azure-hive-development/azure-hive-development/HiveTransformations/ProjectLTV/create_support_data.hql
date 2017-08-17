set hive.enforce.bucketing = true;

DROP TABLE IF EXISTS proj_ltv.support_data;

CREATE TABLE IF NOT EXISTS proj_ltv.support_data
( 
  last_elaboration_day    DATE
)
CLUSTERED BY (last_elaboration_day) INTO 2 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC 
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_Ltv/data/support_data/' 
TBLPROPERTIES ("immutable"="false","transactional"="true");

INSERT OVERWRITE TABLE proj_ltv.support_data
select * from (select '2016-04-3')a
