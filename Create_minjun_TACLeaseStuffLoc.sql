IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseStuffLoc' AND xtype = 'U' )
    Drop table minjun_TACLeaseStuffLoc

CREATE TABLE minjun_TACLeaseStuffLoc
(
    CompanySeq		INT 	 NOT NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    LeaseStuffSerl		INT 	 NOT NULL, 
    LeaseStuffLocName		NVARCHAR(100) 	 NOT NULL, 
    PrivateExtentM		DECIMAL(19,5) 	 NULL, 
    SharingExtentM		DECIMAL(19,5) 	 NULL, 
    PrivateExtentP		DECIMAL(19,5) 	 NULL, 
    SharingExtentP		DECIMAL(19,5) 	 NULL, 
    Remark		NVARCHAR(100) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
CONSTRAINT PKminjun_TACLeaseStuffLoc PRIMARY KEY CLUSTERED (CompanySeq ASC, LeaseStuffSeq ASC, LeaseStuffSerl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseStuffLocLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseStuffLocLog

CREATE TABLE minjun_TACLeaseStuffLocLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    LeaseStuffSerl		INT 	 NOT NULL, 
    LeaseStuffLocName		NVARCHAR(100) 	 NOT NULL, 
    PrivateExtentM		DECIMAL(19,5) 	 NULL, 
    SharingExtentM		DECIMAL(19,5) 	 NULL, 
    PrivateExtentP		DECIMAL(19,5) 	 NULL, 
    SharingExtentP		DECIMAL(19,5) 	 NULL, 
    Remark		NVARCHAR(100) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseStuffLocLog ON minjun_TACLeaseStuffLocLog (LogSeq)
go