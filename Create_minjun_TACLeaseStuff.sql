IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseStuff' AND xtype = 'U' )
    Drop table minjun_TACLeaseStuff

CREATE TABLE minjun_TACLeaseStuff
(
    CompanySeq		INT 	 NOT NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    LeaseStuffName		NVARCHAR(100) 	 NULL, 
    Area		NVARCHAR(100) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
CONSTRAINT PKminjun_TACLeaseStuff PRIMARY KEY CLUSTERED (CompanySeq ASC, LeaseStuffSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseStuffLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseStuffLog

CREATE TABLE minjun_TACLeaseStuffLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    LeaseStuffName		NVARCHAR(100) 	 NULL, 
    Area		NVARCHAR(100) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseStuffLog ON minjun_TACLeaseStuffLog (LogSeq)
go