IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractCost' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractCost

CREATE TABLE minjun_TACLeaseContractCost
(
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    UMCostType		INT 	 NOT NULL, 
    CostAmt		DECIMAL(19,5) 	 NULL, 
    IsCharge		NCHAR(1) 	 NULL, 
    ItemSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
CONSTRAINT PKminjun_TACLeaseContractCost PRIMARY KEY CLUSTERED (CompanySeq ASC, LeaseContSeq ASC, UMCostType ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_TACLeaseContractCostLog' AND xtype = 'U' )
    Drop table minjun_TACLeaseContractCostLog

CREATE TABLE minjun_TACLeaseContractCostLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    LeaseContSeq		INT 	 NOT NULL, 
    UMCostType		INT 	 NOT NULL, 
    CostAmt		DECIMAL(19,5) 	 NULL, 
    IsCharge		NCHAR(1) 	 NULL, 
    ItemSeq		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_TACLeaseContractCostLog ON minjun_TACLeaseContractCostLog (LogSeq)
go