
create database if not exists rawdb;


DROP TABLE IF EXISTS rawdb.MdmGrosvenor;
CREATE EXTERNAL TABLE IF NOT EXISTS rawdb.MdmGrosvenor
(
	groupkeydate STRING,
    groupkeysource STRING,
    gender STRING,
	yearOfBirth  INT,
	grosvenorMemberNumber BIGINT,
	onlineIdGrosvenor BIGINT,
	ballyId BIGINT,
	dateVIPGrosOnl STRING,
	dateVIPGrosRtl STRING,
	dateSelfExcludedFrom STRING,
	dateSelfExcludedTo STRING,
	dateBarredGrosRtlFrom STRING,
	dateBarredGrosRtlTo STRING,
	dateBarredGrosOnlFrom STRING,
	dateBarredGrosOnlTo STRING,
	sourceSystemCode STRING,
	sourceSystemName STRING,
	sourceSystemId INT,
	brand STRING,
	postCodeSector STRING,
	isVIPGrosOnl INT,
	isVIPGrosRtl INT,
	isSelfExcluded INT,
	isBarredGrosRtl INT,
	isBarredGrosOnl INT,
	masterCode STRING,
	rankCode STRING,
	matchStatusCode INT,
	matchStatusName STRING,
	matchGroup BIGINT,
	matchMemberCode BIGINT,
	grosvenorCardNo BIGINT,
	gradeVIPGrosOnl STRING,
	gradeVIPGrosRtl STRING,
	dateFirstRegisteredGrosOnl STRING,
	dateFirstRegisteredGrosRtl STRING,
	sourceModifiedDate STRING,
	mdmModifiedDate STRING,
	versionName STRING,
	versionNumber INT,
	versionFlag  STRING,
	acquisitionChannel STRING,
	acquisitionGroup STRING,
	isCRMPostalGrosOnl INT,
	isCRMTelephoneGrosOnl INT,
	isCRMSMSGrosOnl INT,
	isCRMEmailGrosOnl INT,
	isCRMPostalGrosRtl INT,
	isCRMEmailGrosRtl INT,
	isCRMTelephoneGrosRtl INT,
	isCRMSMSGrosRtl INT,
	dateCRMPostalGrosOnl STRING,
	dateCRMEmailGrosOnl STRING,
	dateCRMTelephoneGrosOnl STRING,
	dateCRMSMSGrosOnl STRING,
	dateCRMTelephoneGrosRtl STRING,
	dateCRMPostalGrosRtl STRING,
	dateCRMEmailGrosRtl STRING,
	dateCRMSMSGrosRtl STRING
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/MDM_GrosvenorCustomer_AllSources_NonPII/';

SELECT * FROM rawdb.MdmGrosvenor LIMIT 100;





DROP TABLE IF EXISTS rawdb.MdmMecca;
CREATE EXTERNAL TABLE IF NOT EXISTS rawdb.MdmMecca
(
	groupkeydate STRING,
    groupkeysource STRING,
    gender STRING,
	yearOfBirth INT,
	meccaCustomerId BIGINT,
	onlineIdMecca BIGINT,
	dateVIPMeccOnl STRING,
	dateVIPMeccRtl STRING,
	dateSelfExcludedFrom STRING,
	dateSelfExcludedTo STRING,
	dateBarredMeccRtlFrom STRING,
	dateBarredMeccRtlTo STRING,
	dateBarredMeccOnlFrom STRING,
	dateBarredMeccOnlTo STRING,
	sourceSystemCode STRING,
	sourceSystemName STRING,
	sourceSystemId INT,
	brand STRING,
	postCodeSector STRING,
	isVIPMeccOnl INT,
	isVIPMeccRtl INT,
	isSelfExcluded INT,
	isBarredMeccRtl INT,
	isBarredMeccOnl INT,
	masterCode  STRING,
	rankCode STRING,
	matchStatusCode INT,
	matchStatusName  STRING,
	matchGroup BIGINT,
	matchMemberCode BIGINT,
	meccaMembershipNoPrimary BIGINT,
	gradeVIPMeccOnl  STRING,
	gradeVIPMeccRtl STRING,
	acquisitionChannel STRING,
	acquisitionGroup STRING,
	dateFirstRegisteredMeccOnl STRING,
	dateFirstRegisteredMeccRtl STRING,
	sourceModifiedDate STRING,
	mdmModifiedDate STRING,
	versionName STRING,
	versionNumber INT,
	versionFlag STRING,
	isCRMPostalMeccOnl INT,
	isCRMTelephoneMeccOnl INT,
	isCRMSMSMeccOnl INT,
	isCRMEmailMeccOnl INT,
	isCRMPostalMeccRtl INT,
	isCRMEmailMeccRtl INT,
	isCRMTelephoneMeccRtl INT,
	isCRMSMSMeccRtl INT,
	dateCRMPostalMeccOnl STRING,
	dateCRMEmailMeccOnl STRING,
	dateCRMTelephoneMeccOnl STRING,
	dateCRMSMSMeccOnl STRING,
	dateCRMTelephoneMeccRtl STRING,
	dateCRMPostalMeccRtl STRING,
	dateCRMEmailMeccRtl STRING,
	dateCRMSMSMeccRtl STRING
   
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 'wasbs://raw@rgdsadldev.blob.core.windows.net/MDM_MeccaCustomer_AllSources_NonPII/';

SELECT * FROM rawdb.MdmMecca LIMIT 100;

