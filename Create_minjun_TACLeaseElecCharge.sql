IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseElecCharge' AND xtype = 'U' )
    Drop table minjun_TACLeaseElecCharge

CREATE TABLE minjun_TACLeaseElecCharge
(
    CompanySeq		INT 	 NOT NULL, 
    AccYM		NCHAR(6) 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    LeaseContSerl		INT 	 NOT NULL, 
    BfrElecMeter		DECIMAL(19,5) 	 NULL, 
    ThisElecMeter		DECIMAL(19,5) 	 NULL, 
    UnitCost		DECIMAL(19,5) 	 NULL, 
    ElecCharge		DECIMAL(19,5) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    AccYMFr		NCHAR(8) 	 NOT NULL, 
    AccYMTo		NCHAR(8) 	 NOT NULL, 
CONSTRAINT PKminjun_TACLeaseElecCharge PRIMARY KEY CLUSTERED (CompanySeq ASC, AccYM ASC, LeaseContSeq ASC, LeaseContSerl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseElecChargeLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseElecChargeLog

CREATE TABLE minjun_TACLeaseElecChargeLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    AccYM		NCHAR(6) 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    LeaseContSerl		INT 	 NOT NULL, 
    BfrElecMeter		DECIMAL(19,5) 	 NULL, 
    ThisElecMeter		DECIMAL(19,5) 	 NULL, 
    UnitCost		DECIMAL(19,5) 	 NULL, 
    ElecCharge		DECIMAL(19,5) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    AccYMFr		NCHAR(8) 	 NOT NULL, 
    AccYMTo		NCHAR(8) 	 NOT NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseElecChargeLog ON minjun_TACLeaseElecChargeLog (LogSeq)
go