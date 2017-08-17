DROP TABLE IF EXISTS proj_galedb.DigitalSpend;
CREATE TABLE IF NOT EXISTS proj_galedb.DigitalSpend
(
    customergoldbrandid STRING,
    brand STRING,
    TotalStakes DOUBLE,
    TotalTheo DOUBLE,
    pctStakesGameBingo DOUBLE,
    pctTheoGameBingo DOUBLE,
    pctStakesGameLive DOUBLE,
    pctTheoGameLive DOUBLE,
    pctStakesGameOther DOUBLE,
    pctTheoGameOther DOUBLE,
  	pctStakesGameCasino DOUBLE,
  	pctTheoGameCasino DOUBLE,
	pctStakesGameBedeOther DOUBLE,
  	pctTheoGameBedeOther DOUBLE,
    pctStakesDeviceMobile DOUBLE,
    pctTheoDeviceMobile DOUBLE,
    pctStakesDeviceOther DOUBLE,
    pctTheoDeviceOther DOUBLE,
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
         ,dimGames.gametypecode as gametypecode
         ,dimGames.gameProviderCode as gameProviderCode
        ,ScalingFactorDigitalSpend.stakefactor
        ,ScalingFactorDigitalSpend.theofactor
    FROM (
        SELECT
            /*+ MAPJOIN(customers) */
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
            ,rapfactgamingactivitydigital.devicetypecode 
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
    LEFT JOIN proj_galedb.dimGames on AggregatedUnionedStakesData.gamecode = dimGames.gamecode
    LEFT JOIN proj_galedb.digitalRTP on dimGames.gametypecode = digitalRTP.gametypecode
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

    ,ROUND(SUM(CASE WHEN gametypecode = 'BINGO' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameBingo
    ,ROUND(SUM(CASE WHEN gametypecode = 'BINGO' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameBingo

    ,ROUND(SUM(CASE WHEN gametypecode = 'OTHER' and gameProviderCode = 'B_Evolution' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameLive
    ,ROUND(SUM(CASE WHEN gametypecode = 'OTHER' and gameProviderCode = 'B_Evolution' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameLive    

    ,ROUND(SUM(CASE WHEN gametypecode = 'OTHER' and gameProviderCode != 'B_Evolution' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameOther
    ,ROUND(SUM(CASE WHEN gametypecode = 'OTHER' and gameProviderCode != 'B_Evolution' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameOther
  	,ROUND(SUM(CASE WHEN gametypecode = 'CASINO' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameCasino
  	,ROUND(SUM(CASE WHEN gametypecode = 'CASINO' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameCasino
	,ROUND(SUM(CASE WHEN gametypecode = 'BEDE_OTHER' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesGameBedeOther
  	,ROUND(SUM(CASE WHEN gametypecode = 'BEDE_OTHER' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoGameBedeOther
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Mobile' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesDeviceMobile
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Mobile' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoDeviceMobile
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Other' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesDeviceOther
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Other' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoDeviceOther
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Desktop' then Stakes else 0 end) / SUM(Stakes), 2) AS pctStakesDeviceDesktop
    ,ROUND(SUM(CASE WHEN devicetypecode = 'Desktop' then Theo else 0 end) / SUM(Theo), 2) AS pctTheoDeviceDesktop
FROM TempDigitalSpendRawdata
GROUP BY brand, customergoldbrandid;


select * from proj_galedb.DigitalSpend LIMIT 100;












