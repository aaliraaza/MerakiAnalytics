set hive.execution.engine=tez; 

SELECT count(*)
FROM proj_meccacustdb.dsc_meccasegmentation_raw
where weekid = '201727' AND segment = 'New';