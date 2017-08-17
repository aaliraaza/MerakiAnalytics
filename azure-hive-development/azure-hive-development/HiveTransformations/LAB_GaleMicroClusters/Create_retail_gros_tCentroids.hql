create database if not exists proj_galedb;
DROP TABLE proj_galedb.retail_gros_tCentroids;
CREATE EXTERNAL TABLE if not exists proj_galedb.retail_gros_tCentroids
( 
    MicroSegment STRING,
    NumVisits DOUBLE,
    Age DOUBLE,
    Tenure DOUBLE,
    ClubEntropy DOUBLE,
    `<20` DOUBLE,
    `<30` DOUBLE,
    `<40` DOUBLE,
    `<50` DOUBLE,
    `<60` DOUBLE,
    `<70` DOUBLE,
    `<80` DOUBLE,
    `Morning` DOUBLE,
    `Day` DOUBLE,
    `Evening` DOUBLE,
    `Night` DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/retail_gros_tCentroids/'
TBLPROPERTIES("skip.header.line.count"="1");