IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegDepositCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegDepositCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ������üũ
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegDepositCheck
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
    SELECT  @TblName    = N'minjun_TACLeaseContractDeposit'
           ,@SeqName    = N'LeaseContSeq'
           ,@SerlName   = N''
           ,@MaxSerl    = 0
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContractDeposit_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#minjun_TACLeaseContractDeposit_' 
    
    IF @@ERROR <> 0 RETURN






    --UMDepositType�� �ߺ�üũ WHY? minjun_TACLeaseContractDeposit ���̺��� Ű���̴�.
       UPDATE  #minjun_TACLeaseContractDeposit_
          SET  Result          = '�����ݱ����� �ߺ��Ǿ����ϴ�.'
              ,MessageType     = 9999
              ,Status          = 9999
         FROM  #minjun_TACLeaseContractDeposit_     AS M
         JOIN  minjun_TACLeaseContractDeposit       AS A     WITH(NOLOCK)   ON  A.CompanySeq      = @CompanySeq
                                                                            AND A.LeaseContSeq    = M.LeaseContSeq
         WHERE A.UMDepositType = M.UMDepositType
    


                        
    UPDATE  #minjun_TACLeaseContractDeposit_
       SET  Result          = '�����ݱ����� �ߺ��Ǿ����ϴ�.'
           ,MessageType     = 9999
           ,Status          = 9999
      FROM  #minjun_TACLeaseContractDeposit_     AS M
            JOIN(   SELECT  X.UMDepositType
                      FROM  minjun_TACLeaseContractDeposit         AS X   WITH(NOLOCK)
                     WHERE  X.CompanySeq    = @CompanySeq
                       AND  NOT EXISTS( SELECT  1
                                          FROM  #minjun_TACLeaseContractDeposit_
                                         WHERE  WorkingTag IN('U', 'D')
                                           AND  Status = 0
                                           AND  LeaseContSeq     = X.LeaseContSeq
                                           )

                    INTERSECT  --������ �ִ� ���� ������ �ֱ� ���� ������ �ִ� �ӽ����̺� ������
                    SELECT  Y.UMDepositType
                      FROM  #minjun_TACLeaseContractDeposit_         AS Y   WITH(NOLOCK)
                     WHERE  Y.WorkingTag IN('A', 'U')
                       AND  Y.Status = 0

                 )AS A    ON  A.UMDepositType  = M.UMDepositType
     WHERE  M.WorkingTag IN('A', 'U')
       AND  M.Status = 0




   -- -- ä���ؾ� �ϴ� ������ �� Ȯ��
   -- SELECT @Count = COUNT(1) FROM #minjun_TACLeaseContractDeposit_ WHERE WorkingTag = 'A' AND Status = 0 
   --  
   -- -- ä��
   -- IF @Count > 0
   -- BEGIN
   --     -- Serl Max�� ��������
   --     SELECT  @MaxSerl    = MAX(ISNULL(A.LeaseContSerl, 0))
   --       FROM  #minjun_TACLeaseContractDeposit_                              AS M
   --             LEFT OUTER JOIN minjun_TACLeaseContractDeposit                AS A  WITH(NOLOCK)  ON  A.CompanySeq          = @CompanySeq
   --                                                                                              AND  A.LeaseContSeq        = M.LeaseContSeq
   --      WHERE  M.WorkingTag IN('A')
   --        AND  M.Status = 0                    
   --     
   --     UPDATE  #minjun_TACLeaseContractDeposit_
   --        SET  UMDepositType = @MaxSerl + DataSeq
   --      WHERE  WorkingTag  = 'A'
   --        AND  Status      = 0
   -- END
   -- 
    SELECT * FROM #minjun_TACLeaseContractDeposit_
    
RETURN