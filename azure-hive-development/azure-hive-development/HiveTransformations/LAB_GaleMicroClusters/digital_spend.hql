SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

create database if not exists proj_galedb;



DROP VIEW IF EXISTS proj_galedb.dsAnnotatedDimGames;
CREATE VIEW IF NOT EXISTS proj_galedb.dsAnnotatedDimGames
AS 
SELECT
    dimgames.gamecode
    ,dimgames.gamename
    ,dimgames.gameprovidercode
    ,dimgames.gamegroupcode
    ,dimgames.gametypecode as rap_gametypecode
    ,dimgames.datasourcecode
    ,dimgames.gamecode_source
    ,dimgames.batchid_insert
    ,dimgames.batchid_update
    ,CASE WHEN dimgames.gameprovidercode in ('B_Bede Bingo', 'B_Bede Bingo V3', 'B_VirtueFusion') and dimgames.gamename like '%Bingo%' then 'BINGO'
            WHEN dimgames.gameprovidercode = 'B_Evolution' and dimgames.gametypecode = 'OTHER' then 'LIVE'
            WHEN dimgames.gameprovidercode = 'B_Microgaming Poker' then 'POKER'
            WHEN opbt.gamename is not null and opbt.category like '%Slots%' then 'SLOTS'
            WHEN opbt.gamename is not null and opbt.category like '%Live%' then 'LIVE'
            WHEN opbt.gamename is not null and opbt.category like '%Bingo%' then 'BINGO'
            WHEN opbt.gamename is not null and opbt.category like '%Mini Game%' then 'MINI_GAME'
            WHEN opbt.gamename is not null and opbt.category like '%Side Games%' then 'MINI_GAME'
            WHEN opbt.gamename is not null and opbt.category like '%Keno%' then 'KENO'    
            else dimgames.gametypecode  end as ds_gametypecode
FROM proj_galedb.dimgames
LEFT JOIN (
    SELECT
        game_name as gamename
        ,groupcategory
        ,category
        ,brand
    FROM (
    select 
            *
            ,row_number() OVER(PARTITION BY game_name order by ABSCode DESC) rownum
        from proj_galedb.opbt_gamecoding
        where brand = 'Mecca'
    ) t1
    where rownum = 1
) opbt
    on dimgames.gamename = opbt.gamename;  




-- Calculate RTP
DROP TABLE IF EXISTS proj_galedb.DigitalRTP;
CREATE TABLE IF NOT EXISTS proj_galedb.DigitalRTP
(
    ds_gametypecode STRING,
    RTP DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/data/digital_rtp';

INSERT OVERWRITE TABLE proj_galedb.DigitalRTP
SELECT
	ds_gametypecode
	,sum(amountpayout) / sum(amountstake) as RTP
FROM (
    SELECT 
        CASE WHEN  actiontypecode = 'Stake' then  amountbasecurrency else 0 end as amountstake
        ,CASE WHEN  actiontypecode = 'Win' then  amountbasecurrency else 0 end as amountpayout
        ,ds_gametypecode
    FROM basedb.rapfactgamingactivitydigital t1
    LEFT JOIN proj_galedb.dsAnnotatedDimGames t2 on t1.gamecode = t2.gamecode
    where basecurrencycode = 'GBP'

    UNION ALL

    SELECT amountstake, amountpayout
       ,ds_gametypecode
    FROM basedb.rapfactgamingactivityfix t1
    LEFT JOIN proj_galedb.dsAnnotatedDimGames t2 on t1.gamecode = t2.gamecode
    where sourcesystemcode IN ('OPBT_MECC', 'OPBT_GROS')

) data
group by ds_gametypecode;







WITH TempDigitalStakeScalingFactorRawdata
AS
(
    SELECT
		    brand, ActivityWeek
		    ,SUM(Stakes) as Stakes
		    ,SUM(Theo) as Theo
	    FROM (
	      SELECT
		      t1.customerkey
		      ,CEIL((datediff(t1.datetimegamingactivity, 
				    t2.registrationdate) + 1) / 7) as ActivityWeek
		      ,t1.amountbasecurrency AS Stakes
		      ,t1.amountbasecurrency * t5.rtp AS Theo
		      ,CASE WHEN sourcesystemcode in ('OPBT_GROS', 'BEDE_GROS') THEN 'DIGITAL_GROS'
				    WHEN sourcesystemcode in ('OPBT_MECC', 'BEDE_MECC') THEN 'DIGITAL_MECC' END AS brand
	      FROM (
					      SELECT
						      customerkey 
						      ,datetimegamingactivity
						      ,amountbasecurrency
						      ,gamecode
					      FROM basedb.rapfactgamingactivitydigital
					      WHERE actiontypecode = 'Stake'
						      AND basecurrencycode = 'GBP'

					      UNION ALL

					      SELECT
						      customerkey
						      ,datetimegamingactivity
						      ,amountstake as amountbasecurrency
						      ,gamecode
					      FROM basedb.rapfactgamingactivityfix t1
                          where sourcesystemcode IN ('OPBT_MECC', 'OPBT_GROS')
				      ) t1
	      LEFT JOIN proj_galedb.dimcustomerattributes t2 
		      ON t1.customerkey = t2.customerkey
	      LEFT JOIN proj_galedb.dimcustomers t3
		      ON t1.customerkey = t3.customerkey
	      LEFT JOIN proj_galedb.dsAnnotatedDimGames t4
		      ON t1.gamecode = t4.gamecode
	      LEFT JOIN proj_galedb.digitalRTP t5 
		      on t4.ds_gametypecode = t5.ds_gametypecode
	      WHERE datediff(to_date(current_timestamp), 
					     t2.registrationdate) >= 365
	    )Stakes
	    WHERE ActivityWeek <= 52
	    GROUP BY brand, ActivityWeek
)
INSERT OVERWRITE TABLE proj_galedb.ScalingFactorDigitalSpend
SELECT
	StakeCumSum.brand, StakeCumSum.ActivityWeek
	,Total.Stakes / StakeCumSum.Stakes AS StakeFactor
	,Total.Theo / StakeCumSum.Theo AS TheoFactor
FROM (
  SELECT
	  brand, ActivityWeek
	  ,SUM(Stakes) OVER(PARTITION BY brand ORDER BY ActivityWeek ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Stakes
	  ,SUM(Theo) OVER(PARTITION BY brand ORDER BY ActivityWeek ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Theo
  FROM TempDigitalStakeScalingFactorRawdata
) StakeCumSum
LEFT JOIN (
  	SELECT 
  		brand
  		,SUM(Stakes) as Stakes
  		,SUM(Theo) AS Theo
  	FROM TempDigitalStakeScalingFactorRawdata
  	GROUP BY brand
) Total
	ON Total.brand = StakeCumSum.brand
WHERE StakeCumSum.ActivityWeek > 12
ORDER BY StakeCumSum.brand, StakeCumSum.ActivityWeek;

SELECT * FROM proj_galedb.ScalingFactorDigitalSpend;


DROP TABLE IF EXISTS proj_galedb.DigitalSpend;
CREATE TABLE IF NOT EXISTS proj_galedb.DigitalSpend
(
    customergoldbrandid STRING,
    brand STRING,
    TotalStakes DOUBLE,
    TotalTheo DOUBLE,
    pctStakesGameBingo DOUBLE,
    pctTheoGameBingo DOUBLE,
    pctStakesGameMini DOUBLE,
    pctTheoGameMini DOUBLE,
    pctStakesGameSlots DOUBLE,
    pctTheoGameSlots DOUBLE,
  	pctStakesGameOther DOUBLE,
  	pctTheoGameOther DOUBLE,
    pctStakesDeviceMobile DOUBLE,
    pctTheoDeviceMobile DOUBLE,
    pctStakesDeviceDesktop DOUBLE,
    pctTheoDeviceDesktop DOUBLE
)
CLUSTERED BY (brand, customergoldbrandid) INTO 10 BUCKETS
SKEWED BY (brand) ON ('OPBT_MECC', 'BEDE_MECC')
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS ORC
LOCATION 'wasbs://lab@rgdsadldev.blob.core.windows.net/PROJ_GaleMicroClustering/features/digital_spend';




WITH TempDigitalSpendRawdata 
AS
(
    SELECT
          AggregatedUnionedStakesData.*
         ,ROUND(AggregatedUnionedStakesData.Stakes * (1.0 - digitalRTP.rtp), 2) as Theo
         ,dsAnnotatedDimGames.ds_gametypecode
         ,dsAnnotatedDimGames.gameProviderCode as gameProviderCode
        ,ScalingFactorDigitalSpend.stakefactor
        ,ScalingFactorDigitalSpend.theofactor
    FROM (
        SELECT
            /*+ MAPJOIN(TempCustomersWithTenure) */
            customergoldbrandid, brand, gamecode, devicetypecode
            ,sum(Stakes) as Stakes
            ,max(digitaltenure) as digitaltenure
    FROM (
        SELECT
            rapfactgamingactivityfix.customerkey
            ,rapfactgamingactivityfix.gamecode
            ,case when rapfactgamingactivityfix.venuecode in ('OB_B', 'OB_M', 'OB_C') Then 'Mobile' else 'Desktop' end as devicetypecode
            ,rapfactgamingactivityfix.amountstake as Stakes
        FROM basedb.rapfactgamingactivityfix 
        WHERE rapfactgamingactivityfix.sourcesystemcode IN ('OPBT_MECC', 'OPBT_GROS')
             and rapfactgamingactivityfix.groupkeydate >= date_sub(current_date, 365)
        UNION ALL 

        SELECT
            rapfactgamingactivitydigital.customerkey
            ,rapfactgamingactivitydigital.gamecode
            ,case when rapfactgamingactivitydigital.devicetypecode = 'Other' then 'Mobile' else rapfactgamingactivitydigital.devicetypecode end as devicetypecode
            ,rapfactgamingactivitydigital.amountbasecurrency as Stakes
        FROM basedb.rapfactgamingactivitydigital       
        WHERE rapfactgamingactivitydigital.actiontypecode = 'Stake'
	        AND rapfactgamingactivitydigital.basecurrencycode = 'GBP'
            and rapfactgamingactivitydigital.groupkeydate >= date_sub(current_date, 365)

    ) UnionedStakesData
    LEFT JOIN (
         SELECT
	        /*+ MAPJOIN(dimcustomersdigital) */
            dimcustomersdigital.customerkey
	        ,customertenure.customergoldbrandid
            ,customertenure.brand
            ,customertenure.digitaltenure   
        FROM proj_galedb.dimcustomersdigital
        LEFT JOIN proj_galedb.customertenure
	        ON dimcustomersdigital.customergoldbrandid = customertenure.customergoldbrandid
            WHERE customertenure.digitaltenure > 3*4*7
    ) TempCustomersWithTenure ON UnionedStakesData.customerkey = TempCustomersWithTenure.customerkey
    group by customergoldbrandid, brand, gamecode, devicetypecode
) AggregatedUnionedStakesData
    LEFT JOIN proj_galedb.dsAnnotatedDimGames 
		      ON AggregatedUnionedStakesData.gamecode = dsAnnotatedDimGames.gamecode    
    LEFT JOIN proj_galedb.digitalRTP on  dsAnnotatedDimGames.ds_gametypecode = digitalRTP.ds_gametypecode
    LEFT JOIN proj_galedb.ScalingFactorDigitalSpend 
        ON SPLIT(AggregatedUnionedStakesData.brand, '_')[1] = SPLIT(ScalingFactorDigitalSpend.brand, '_')[1]
        AND (CEIL(AggregatedUnionedStakesData.digitaltenure / 7) + 1) = ScalingFactorDigitalSpend.ActivityWeek
)
INSERT OVERWRITE TABLE proj_galedb.DigitalSpend
SELECT
	customergoldbrandid, brand
	,ROUND(CASE WHEN MAX(digitaltenure) < 365 THEN MAX(stakefactor) ELSE 1 END * 
            SUM(Stakes), 2) AS TotalStakes
    ,ROUND(CASE WHEN MAX(digitaltenure) < 365 THEN MAX(theofactor) ELSE 1 END * 
            SUM(Theo), 2) AS TotalTheo

    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'BINGO' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameBingo
    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'BINGO' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameBingo

    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'MINI_GAME' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameMini
    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'MINI_GAME' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameMini    

    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'CASINO' or ds_gametypecode = 'SLOTS' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameSlots
  	,ROUND(SUM(CASE WHEN ds_gametypecode = 'CASINO' or ds_gametypecode = 'SLOTS' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameSlots

    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'OTHER' or ds_gametypecode = 'KENO' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameOther
    ,ROUND(SUM(CASE WHEN ds_gametypecode = 'OTHER' or ds_gametypecode = 'KENO' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameOther

    ,ROUND(SUM(CASE WHEN devicetypecode = 'Mobile' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesDeviceMobile
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Mobile' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoDeviceMobile

    ,ROUND(SUM(CASE WHEN devicetypecode = 'Desktop' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesDeviceDesktop
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Desktop' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoDeviceDesktop
FROM TempDigitalSpendRawdata
GROUP BY brand, customergoldbrandid;


select * from proj_galedb.DigitalSpend LIMIT 100;
