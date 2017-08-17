SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

DROP TABLE IF EXISTS proj_ltv.customer_base_status;
CREATE TABLE if not exists proj_ltv.customer_base_status 
(   
   customerkey BIGINT,
   churn_date DATE,
   reactivated   SMALLINT,
   cum_theo_CLV DOUBLE,
   last_date_activity DATE  

)
PARTITIONED BY (groupkeydate STRING)
CLUSTERED BY(customerkey) INTO 10 BUCKETS 
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_Ltv/data/customer_base_status/';