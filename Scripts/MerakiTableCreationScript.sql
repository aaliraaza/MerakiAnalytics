/*
Deployment script for merakidb

*/

Use merakidb

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;



GO


PRINT N'Creating [dbo].[tblMeraki]...';


GO
CREATE TABLE [dbo].[tblMeraki] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [Version]      VARCHAR (5)  NULL,
    [Secret]       VARCHAR (50) NULL,
    [Type]         VARCHAR (20) NULL,
    [apFloors]     VARCHAR (50) NULL,
    [apTags]       VARCHAR (50) NULL,
    [apMac]        VARCHAR (50) NULL,
    [manufacturer] VARCHAR (50) NULL,
    [lng]          DECIMAL (18) NULL,
    [lat]          DECIMAL (18) NULL,
    [x]            DECIMAL (18) NULL,
    [y]            DECIMAL (18) NULL,
    [unc]          DECIMAL (18) NULL,
    [seentime]     DATETIME     NULL,
    [ssid]         VARCHAR (50) NULL,
    [os]           CHAR (10)    NULL,
    [clientMac]    VARCHAR (50) NULL,
    [seenEpoch]    VARCHAR (50) NULL,
    [rssi]         VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO


GO


PRINT N'Update complete.';


GO
