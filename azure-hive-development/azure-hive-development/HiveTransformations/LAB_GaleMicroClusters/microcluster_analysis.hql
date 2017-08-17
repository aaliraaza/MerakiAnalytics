


DROP TABLE IF EXISTS  proj_galedb.bluevennLookup;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.bluevennLookup
(
    bvcontactid STRING,
    opbtcustomerid STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/digital_customer_bv_lookup/'
tblproperties("skip.header.line.count"="1"); 


select *
from proj_galedb.bluevennLookup
limit 100;




DROP TABLE IF EXISTS  proj_galedb.opbttheofy2015;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.opbttheofy2015
(
    opbtcustomerid STRING,
    totaltheo DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/opbt_theo_cal2015/'
tblproperties("skip.header.line.count"="1"); 


select *
from proj_galedb.opbttheofy2015
limit 100;





DROP TABLE IF EXISTS  proj_galedb.historicMeccaClusters;
CREATE EXTERNAL TABLE IF NOT EXISTS proj_galedb.historicMeccaClusters
(
    bvcontactid STRING,
    microcluster STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' lines terminated by '\n'
STORED AS TEXTFILE
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/external_data/historic_mecca_digital_clusters'
tblproperties("skip.header.line.count"="1"); 

-- historic customer base
select
	historicMircoCluster, latestMicroCluster
	,count(customergoldbrandid) as customers
	,coalesce(sum(totaltheo), 0.0) as totaltheo
from (
  select 
	  dimcustomersdigital.customergoldbrandid
	  ,historicMeccaClusters.microcluster as historicMircoCluster
	  ,coalesce(digital_mecca_microsegments.microsegment, 'Churned') as latestMicroCluster
  	  ,digitalspend.totaltheo as totaltheo
      ,row_number() OVER(partition by historicMeccaClusters.bvcontactid) as rownum
  from proj_galedb.historicMeccaClusters
  left join proj_galedb.bluevennLookup
	  on historicMeccaClusters.bvcontactid = bluevennLookup.bvcontactid
  left join proj_galedb.dimcustomersdigital 
	  on dimcustomersdigital.customerid_source = bluevennLookup.opbtcustomerid
  left join proj_galedb.digital_mecca_microsegments
	  on digital_mecca_microsegments.customergoldbrandid = dimcustomersdigital.customergoldbrandid
  left join proj_galedb.digitalspend 
	on digital_mecca_microsegments.customergoldbrandid = digitalspend.customergoldbrandid
  where historicMeccaClusters.microcluster is not null
    and dimcustomersdigital.customergoldbrandid != '-1'
) t1
where rownum = 1
group by historicMircoCluster, latestMicroCluster;


-- new customers
select
	microsegment
	,count(*) as customers
	,sum(totaltheo) as totaltheo
from (
  select 
	  digital_mecca_microsegments.customergoldbrandid
	  ,digital_mecca_microsegments.microsegment
	  ,COALESCE(MAX(digitalspend.totaltheo), 0.0) as totaltheo
      ,max(historicMeccaClusters.microcluster) as historicmicrocluster
  from proj_galedb.digital_mecca_microsegments
  left join proj_galedb.digitalspend 
	  on digital_mecca_microsegments.customergoldbrandid = digitalspend.customergoldbrandid
  left join proj_galedb.dimcustomersdigital
	  on dimcustomersdigital.customergoldbrandid = digital_mecca_microsegments.customergoldbrandid
  left join proj_galedb.bluevennLookup
	  on dimcustomersdigital.customerid_source = bluevennLookup.opbtcustomerid
  left join proj_galedb.historicMeccaClusters
	  on historicMeccaClusters.bvcontactid = bluevennLookup.bvcontactid
  where historicMeccaClusters.microcluster is null
	  and digital_mecca_microsegments.microsegment is not null
	  and dimcustomersdigital.customergoldbrandid != '-1'
  group by digital_mecca_microsegments.customergoldbrandid,
	  digital_mecca_microsegments.microsegment
) t1
where historicmicrocluster is null
group by microsegment;




SELECT microsegment, count(*) as C, sum(totaltheo) as totaltheo 
from proj_galedb.digital_mecca_microsegments
left join proj_galedb.digitalspend 
	on digital_mecca_microsegments.customergoldbrandid = digitalspend.customergoldbrandid
group by microsegment;



select 
	microsegment, iscrosschannel
	,count(*)
	,sum(totaltheo) as totaltheo
from (
  SELECT 
	  digital_mecca_microsegments.customergoldbrandid
	  ,microsegment
	  ,case when retailtenure is not null then 1 else 0 end as isCrossChannel
  	  ,totaltheo
  from proj_galedb.digital_mecca_microsegments
  left join proj_galedb.customertenure 
	  on digital_mecca_microsegments.customergoldbrandid = customertenure.customergoldbrandid
  left join proj_galedb.digitalspend 
	on digital_mecca_microsegments.customergoldbrandid = digitalspend.customergoldbrandid
) t1
group by microsegment, iscrosschannel;



select
	SUM(pcttheodevicedesktop * pcttheogamebingo * totaltheo) as DesktopBingo
	,SUM(pcttheodevicemobile * pcttheogamebingo * totaltheo) as MobileBingo
	,SUM(pcttheodevicedesktop * pcttheogameslots * totaltheo) as DesktopSlots
	,SUM(pcttheodevicemobile * pcttheogameslots * totaltheo) as MobileSlots
	,SUM(pcttheodevicedesktop * pcttheogamemini * totaltheo) as DesktopMini
	,SUM(pcttheodevicemobile * pcttheogamemini * totaltheo) as MobileMini
	,SUM(pcttheodevicedesktop * pcttheogameother * totaltheo) as DesktopOther
	,SUM(pcttheodevicemobile * pcttheogameother * totaltheo) as MobileOther
from proj_galedb.digitalspend;


SELECT 
	explode(histogram_numeric(totaltheo * pcttheogamebingo, 100)) AS xbingo
FROM digitalspend;


SELECT
	explode(histogram_numeric(totaltheo * pcttheogameslots, 100)) AS xslots
FROM digitalspend;
	

SELECT
	explode(histogram_numeric(totaltheo * pcttheogamemini, 100)) AS xmini
FROM digitalspend;
	

SELECT 
	explode(histogram_numeric(totaltheo * pcttheogameother, 100)) AS xother
FROM digitalspend;

SELECT 
	explode(histogram_numeric(totaltheo * pcttheodevicedesktop, 100)) AS xdesktop
FROM digitalspend;


SELECT
	explode(histogram_numeric(totaltheo * pcttheodevicemobile, 100)) AS xmobile
FROM digitalspend;