create database if not exists proj_meccacustdb;
DROP TABLE proj_meccacustdb.DSC_MeccaSegmentation_raw;
CREATE EXTERNAL TABLE if not exists proj_meccacustdb.DSC_MeccaSegmentation_raw
( 
    customerKey int, 
    venueAreaDesc string,
    venueDesc string,
    visitStartTime string, 
    sessName string,
    weekId string,
    periodId string,
    Year int,
    FiscDayOfWeek int,
    FiscWeekOfYear int,
    FiscQuarter string,
    FiscQuarterOfYear int,
    weekStart string,
    registrationDate string,
    gender string,
    Age int,
    Segment string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/MeccaSegmentationGC/'
TBLPROPERTIES("skip.header.line.count"="1");