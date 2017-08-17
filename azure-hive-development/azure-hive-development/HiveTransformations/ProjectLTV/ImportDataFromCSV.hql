CREATE TABLE IF NOT EXISTS proj_ltv.CustomerDetails

(
Bede_User_ID  BIGINT,
Title STRING,
Age INT,
Birthday TIMESTAMP,
Post_Code STRING,
City STRING,
Retail_Membership_Number STRING,
ContactPreference_Email INT,
ContactPreference_Post INT,
ContactPreference_Push INT,
ContactPreference_Telephone INT
)

ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS ORC;

LOAD DATA INPATH 'wasbs://ltvdatapent@rgdsadldev.blob.core.windows.net/CustomerDetail.csv/' OVERWRITE INTO TABLE proj_ltv.CustomerDetails;