CREATE TABLE IF NOT EXISTS proj_ltv.game_data_fields
( 
  name_field    STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_Ltv/data/game_data_fields/';

INSERT OVERWRITE TABLE proj_ltv.game_data_fields
select * from (select 'datetimegamingactivity')datetimegamingactivity
UNION
select * from (select 'customerkey')customerkey;
