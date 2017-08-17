

DROP TABLE IF EXISTS proj_galedb.digital_mecca_microsegments;
CREATE TABLE IF NOT EXISTS proj_galedb.digital_mecca_microsegments
(
    customergoldbrandid STRING,
    Microsegment STRING
)
CLUSTERED BY (customergoldbrandid) INTO 1 BUCKETS
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/scoring/mecc_digital_SegmentationScores';

with meccadigitalcustomers 
as (
    select customergoldbrandid, sourcesystemcode
    from proj_galedb.dimcustomers
    where sourcesystemcode in ('BEDE_MECC', 'OPBT_MECC')
  		and customergoldbrandid != '-1'
),
meccaclusterdistances as
(
  select
	  rawdata.customergoldbrandid
	  ,digital_mecc_tCentroids.microsegment
	  ,sqrt(power(rawdata.TotalTheo - digital_mecc_tCentroids.DigitalSpend, 2) 
		+ power((rawdata.digitaltenure / 365.0) - (digital_mecc_tCentroids.digitalTenure), 2) 
		+ power((rawdata.retailtenure / 365.0) - (digital_mecc_tCentroids.retailtenure), 2)
		+ power(rawdata.pcttheodevicedesktop - digital_mecc_tCentroids.desktop, 2)
		+ power(rawdata.pcttheodevicemobile - digital_mecc_tCentroids.mobile, 2)
		+ power(rawdata.pcttheogamebingo - digital_mecc_tCentroids.bingo, 2)
		+ power(rawdata.pcttheogameslots - digital_mecc_tCentroids.slots, 2)
        + power(rawdata.pcttheogamemini - digital_mecc_tCentroids.minigame, 2)
        + power(rawdata.pcttheogameother - digital_mecc_tCentroids.other, 2)
	  ) as Distance
  from (
	select
		meccadigitalcustomers.customergoldbrandid
		,COALESCE(customertenure.digitaltenure, 0) as digitaltenure
		,COALESCE(customertenure.retailtenure, 0) as retailtenure
		,COALESCE(digitalspend.totaltheo, 0.0) as TotalTheo
		,COALESCE(digitalspend.pcttheodevicedesktop, 0.0) as pcttheodevicedesktop
		,COALESCE(digitalspend.pcttheodevicemobile, 0.0) as pcttheodevicemobile
		,COALESCE(digitalspend.pcttheogamebingo, 0.0) as pcttheogamebingo
		,COALESCE(digitalspend.pcttheogameslots, 0.0) as pcttheogameslots
        ,COALESCE(digitalspend.pcttheogamemini, 0.0) as pcttheogamemini
        ,COALESCE(digitalspend.pcttheogameother, 0.0) as pcttheogameother
	from meccadigitalcustomers
	left join proj_galedb.customertenure 
		on meccadigitalcustomers.customergoldbrandid = customertenure.customergoldbrandid
	left join proj_galedb.digitalspend 
		on meccadigitalcustomers.customergoldbrandid = digitalspend.customergoldbrandid
    where digitalspend.customergoldbrandid is not null
  ) rawdata
  cross join proj_galedb.digital_mecc_tCentroids
)
INSERT OVERWRITE TABLE proj_galedb.digital_mecca_microsegments
SELECT
    customergoldbrandid
    ,microsegment
FROM  (
    select *
        ,row_number() OVER (PARTITION BY customergoldbrandid ORDER BY Distance ASC) as rownum
    from  meccaclusterdistances
    ) t1
where rownum = 1



