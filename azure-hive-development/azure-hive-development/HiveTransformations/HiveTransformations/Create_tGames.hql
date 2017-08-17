DROP TABLE tGames;
CREATE EXTERNAL TABLE tGames (t1 string, t2 string, t3 string, t4 string, t5 string, t6 string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/BALLY_tGame/';