set hive.execution.engine=tez;


SELECT *
FROM rawdb.rapfactgamingactivity 
where groupkeydate = '2016-01-01' LIMIT 100;
