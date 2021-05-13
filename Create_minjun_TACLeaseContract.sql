IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContract' AND xtype = 'U' )
    Drop table minjun_TACLeaseContract

CREATE TABLE minjun_TACLeaseContract
(
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    LeaseContName		NVARCHAR(100) 	 NOT NULL, 
    LeaseContNo		NVARCHAR(20) 	 NOT NULL, 
    ContractDate		NCHAR(8) 	 NOT NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    TenantSeq		INT 	 NOT NULL, 
    ChargePerson		NVARCHAR(100) 	 NOT NULL, 
    ChargePersonTel		NVARCHAR(50) 	 NULL, 
    ChargePersonEmail		NVARCHAR(50) 	 NULL, 
    UMContractType		INT 	 NULL, 
    UMPayMonthType		INT 	 NULL, 
    LeaseDateFr		NCHAR(8) 	 NOT NULL, 
    LeaseDateTo		NCHAR(8) 	 NOT NULL, 
    ParkingCnt		INT 	 NULL, 
    ManageEmp		NVARCHAR(100) 	 NULL, 
    Purpose		NVARCHAR(100) 	 NULL, 
    SpecialNote		NVARCHAR(500) 	 NULL, 
    FileSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
CONSTRAINT PKminjun_TACLeaseContract PRIMARY KEY CLUSTERED (CompanySeq ASC, LeaseContSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractLog

CREATE TABLE minjun_TACLeaseContractLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    LeaseContName		NVARCHAR(100) 	 NOT NULL, 
    LeaseContNo		NVARCHAR(20) 	 NOT NULL, 
    ContractDate		NCHAR(8) 	 NOT NULL, 
    LeaseStuffSeq		INT 	 NOT NULL, 
    TenantSeq		INT 	 NOT NULL, 
    ChargePerson		NVARCHAR(100) 	 NOT NULL, 
    ChargePersonTel		NVARCHAR(50) 	 NULL, 
    ChargePersonEmail		NVARCHAR(50) 	 NULL, 
    UMContractType		INT 	 NULL, 
    UMPayMonthType		INT 	 NULL, 
    LeaseDateFr		NCHAR(8) 	 NOT NULL, 
    LeaseDateTo		NCHAR(8) 	 NOT NULL, 
    ParkingCnt		INT 	 NULL, 
    ManageEmp		NVARCHAR(100) 	 NULL, 
    Purpose		NVARCHAR(100) 	 NULL, 
    SpecialNote		NVARCHAR(500) 	 NULL, 
    FileSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseContractLog ON minjun_TACLeaseContractLog (LogSeq)
go