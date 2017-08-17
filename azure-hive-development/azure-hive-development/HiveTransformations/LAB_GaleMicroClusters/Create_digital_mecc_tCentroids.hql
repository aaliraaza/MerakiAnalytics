create database if not exists proj_galedb;
DROP TABLE proj_galedb.digital_mecc_tCentroids;
CREATE EXTERNAL TABLE if not exists proj_galedb.digital_mecc_tCentroids
( 
    MicroSegment STRING,
    DigitalSpend Double,	
    DigitalTenure Double,	
    RetailTenure Double,	
    VIP Double,	
    VisitedRetail Double,	
    RetailVisits Double,	
    Desktop Double,	
    Mobile Double,	
    Bingo Double,	
    Slots Double,	
    MiniGame Double,	
    Other Double
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/digital_mecc_tCentroids/'
TBLPROPERTIES("skip.header.line.count"="1");