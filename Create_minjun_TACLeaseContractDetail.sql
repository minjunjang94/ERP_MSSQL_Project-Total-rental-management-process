IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractDetail' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractDetail

CREATE TABLE minjun_TACLeaseContractDetail
(
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    LeaseContSerl		INT 	 NOT NULL, 
    LeaseStuffSerl		INT 	 NULL, 
    Remark		NVARCHAR(100) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    LastDateTime		DATETIME 	 NULL, 
CONSTRAINT PKminjun_TACLeaseContractDetail PRIMARY KEY CLUSTERED (CompanySeq ASC, LeaseContSeq ASC, LeaseContSerl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractDetailLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractDetailLog

CREATE TABLE minjun_TACLeaseContractDetailLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    LeaseContSerl		INT 	 NOT NULL, 
    LeaseStuffSerl		INT 	 NULL, 
    Remark		NVARCHAR(100) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    LastDateTime		DATETIME 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseContractDetailLog ON minjun_TACLeaseContractDetailLog (LogSeq)
go