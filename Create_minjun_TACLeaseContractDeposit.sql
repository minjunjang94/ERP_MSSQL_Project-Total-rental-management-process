IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractDeposit' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractDeposit

CREATE TABLE minjun_TACLeaseContractDeposit
(
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    UMDepositType		INT 	 NOT NULL, 
    Rate		INT 	 NULL, 
    Amt		DECIMAL(19,5) 	 NULL, 
    PayDate		NCHAR(8) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
CONSTRAINT PKminjun_TACLeaseContractDeposit PRIMARY KEY CLUSTERED (CompanySeq ASC, LeaseContSeq ASC, UMDepositType ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractDepositLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractDepositLog

CREATE TABLE minjun_TACLeaseContractDepositLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    UMDepositType		INT 	 NOT NULL, 
    Rate		INT 	 NULL, 
    Amt		DECIMAL(19,5) 	 NULL, 
    PayDate		NCHAR(8) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseContractDepositLog ON minjun_TACLeaseContractDepositLog (LogSeq)
go