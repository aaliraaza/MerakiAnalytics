--MSCK REPAIR TABLE basedb.xchannel_xbrand_visits;

--Select * FROM basedb.xchannel_xbrand_visits
--WHERE groupkeydate rlike '2016-08.*' LIMIT 10;

--Select * FROM proj_meccacustdb.DSC_MeccaSegmentation
--Where weekid > 201652 LIMIT 1000;

--Select * FROM basedb.rapfactgamingactivityfix limit 10;
--    WHERE groupkeydate rlike '2016-06.*' AND sec_venueareacode rlike 'GRTL.*';

--analyze table basedb.xchannel_xbrand_visits PARTITION(groupkeydate) compute statistics;
--analyze table basedb.xchannel_xbrand_visits PARTITION(groupkeydate) compute statistics for columns;

-- DISTINCT(datasourcecode)  FROM proj_galedb.dimgames

--DROP TABLE proj_galedb.gros_SegmentationScore