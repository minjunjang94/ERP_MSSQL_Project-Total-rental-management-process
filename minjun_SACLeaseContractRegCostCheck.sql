IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegCostCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegCostCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : û��üũ
 �ۼ��� - '2020-04-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegCostCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@MaxSerl        INT             -- Serl�� �ִ밪
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'minjun_TACLeaseContractCost'
           ,@SeqName    = N'LeaseContSeq'
           ,@SerlName   = N''
           ,@MaxSerl    = 0
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContractCost_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock4', '#minjun_TACLeaseContractCost_' 
    
    IF @@ERROR <> 0 RETURN


    --UMCostType�� �ߺ�üũ WHY? minjun_TACLeaseContractCost ���̺��� Ű���̴�.







   -- -- ä���ؾ� �ϴ� ������ �� Ȯ��
   -- SELECT @Count = COUNT(1) FROM #minjun_TACLeaseContractCost_ WHERE WorkingTag = 'A' AND Status = 0 
   --  
   -- -- ä��
   -- IF @Count > 0
   -- BEGIN
   --     -- Serl Max�� ��������
   --     SELECT  @MaxSerl    = MAX(ISNULL(A.LeaseContSerl, 0))
   --       FROM  #minjun_TACLeaseContractCost_                              AS M
   --             LEFT OUTER JOIN minjun_TACLeaseContractCost                AS A  WITH(NOLOCK)  ON  A.CompanySeq          = @CompanySeq
   --                                                                                              AND  A.LeaseContSeq        = M.LeaseContSeq
   --      WHERE  M.WorkingTag IN('A')
   --        AND  M.Status = 0                    
   --     
   --     UPDATE  #minjun_TACLeaseContractCost_
   --        SET  UMDepositType = @MaxSerl + DataSeq
   --      WHERE  WorkingTag  = 'A'
   --        AND  Status      = 0
   -- END
   -- 
   SELECT * FROM #minjun_TACLeaseContractCost_
    
RETURN