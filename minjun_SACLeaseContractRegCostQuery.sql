IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegCostQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegCostQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : û����ȸ
 �ۼ��� - '2020-04-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegCostQuery
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
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock4', @xmlFlags)
      WITH (LeaseContSeq        INT)
    
    -- ����Select
    SELECT	 
            
             A.LeaseContSeq
            ,A.UMCostType           AS  UMCostTypeSeq
            ,D.MinorName            AS  UMPayMonthTypeName
            ,C.UMPayMonthType       AS  UMPayMonthType
            ,A.CostAmt
            ,A.IsCharge
            ,B.ItemName
            ,B.ItemSeq
			 

								
    FROM    minjun_TACLeaseContractCost               AS  A   WITH(NOLOCK)
    LEFT OUTER JOIN _TDAItem                          AS  B                     ON B.CompanySeq     = A.CompanySeq
                                                                               AND B.ItemSeq        = A.ItemSeq
    LEFT OUTER JOIN minjun_TACLeaseContract           AS  C                     ON C.CompanySeq     = A.CompanySeq
                                                                               AND C.LeaseContSeq   = A.LeaseContSeq
    LEFT OUTER JOIN _TDAUMinor                        AS  D                     ON D.CompanySeq     = C.CompanySeq
                                                                               AND D.MinorSeq       = C.UMPayMonthType

                                                                               
    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseContSeq    = @LeaseContSeq
      
RETURN

SELECT * FROM  minjun_TACLeaseStuff
SELECT * FROM  minjun_TACLeaseStuffLoc