create database if not exists proj_meccacustdb;
DROP TABLE proj_meccacustdb.DSC_MeccaSegmentation2;
CREATE TABLE if not exists proj_meccacustdb.DSC_MeccaSegmentation2 AS
SELECT
    customerKey, 
    venueAreaDesc,
    venueDesc,
    from_utc_timestamp(UNIX_TIMESTAMP(visitStartTime, "yyyy-MM-dd hh:mm:ss.SSSSSSSSS")*1000,'GMT') as visitStartTime, 
    sessName,
    weekId,
    periodId,
    Year,
    FiscDayOfWeek,
    FiscWeekOfYear,
    FiscQuarter,
    FiscQuarterOfYear,
    from_utc_timestamp(UNIX_TIMESTAMP(weekStart, "yyyy-MM-dd hh:mm:ss")*1000,'GMT') as weekStart,
    from_utc_timestamp(UNIX_TIMESTAMP(registrationDate, "yyyy-MM-dd hh:mm:ss")*1000,'GMT') as registrationDate,
    gender,
    Age,
    Segment
FROM proj_meccacustdb.DSC_MeccaSegmentation_raw;