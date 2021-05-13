IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegDepositQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegDepositQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ��������ȸ
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegDepositQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml������
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
   ,@UserSeq        INT            = 0     -- ����� ��ȣ
   ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle           INT
           ,@LeaseContSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT @LeaseContSeq         = RTRIM(LTRIM(ISNULL(LeaseContSeq          , 0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock3', @xmlFlags)
      WITH (LeaseContSeq        INT)
    
    -- ����Select
    SELECT	 
            
             A.LeaseContSeq
            ,A.UMDepositType   AS  UMDepositTypeSeq
            ,A.Rate
            ,A.Amt
            ,A.PayDate


								
    FROM    minjun_TACLeaseContractDeposit               AS  A   WITH(NOLOCK)

    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseContSeq     = @LeaseContSeq
      
RETURN

SELECT * FROM  minjun_TACLeaseStuff
SELECT * FROM  minjun_TACLeaseStuffLoc