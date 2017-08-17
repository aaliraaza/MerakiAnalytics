CREATE TABLE IF NOT EXISTS proj_ltv.gamegroup
( 
  gamecode    STRING,
  gamegroupid STRING,
  gametypecode STRING,
  gameprovider STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_Ltv/data/gamegroup/';


INSERT OVERWRITE TABLE proj_ltv.gamegroup
SELECT 
    gamecode, 
	concat(gameprovidercode, gametypecode), 
	gameprovidercode, 
	gametypecode 
FROM proj_galedb.dimgames;