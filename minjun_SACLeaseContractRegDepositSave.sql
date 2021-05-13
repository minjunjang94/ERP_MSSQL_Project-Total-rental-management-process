IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegDepositSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegDepositSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ����������
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegDepositSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@LeaseStuffSerlName       NVARCHAR(MAX)   -- LeaseStuffSerl��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName                  = N'minjun_TACLeaseContractDeposit'
           ,@SeqName                  = N'LeaseContSeq'
           ,@LeaseStuffSerlName       = N''

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContractDeposit_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#minjun_TACLeaseContractDeposit_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		        -- ���̺��      
                  '#minjun_TACLeaseContractDeposit_',		        -- �ӽ� ���̺��      
                  'LeaseContSeq,UMDepositType',              -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,               -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractDeposit_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        DELETE  A
          FROM  #minjun_TACLeaseContractDeposit_                          AS M
                JOIN minjun_TACLeaseContractDeposit            AS A  WITH(NOLOCK)  ON   A.CompanySeq         = @CompanySeq
                                                                                   AND  A.LeaseContSeq      = M.LeaseContSeq
                                                                                   AND  A.UMDepositType     = M.UMDepositTypeSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractDeposit_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TACLeaseContractDeposit 
           SET  
                 Rate               = M.Rate      
                ,Amt                = M.Amt       
                ,PayDate            = M.PayDate   
                ,LastUserSeq        = @UserSeq
                ,LastDateTime       = GETDATE()




               
          FROM  #minjun_TACLeaseContractDeposit_                          AS M
                JOIN minjun_TACLeaseContractDeposit                       AS A  WITH(NOLOCK)  ON   A.CompanySeq        = @CompanySeq
                                                                                              AND  A.LeaseContSeq      = M.LeaseContSeq
                                                                                              AND  A.UMDepositType     = M.UMDepositTypeSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractDeposit_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TACLeaseContractDeposit (
                     CompanySeq
                    ,LeaseContSeq
                    ,UMDepositType
                    ,Rate        
                    ,Amt         
                    ,PayDate     
                    ,LastUserSeq 
                    ,LastDateTime
                    
                    
                    

            )
            SELECT   @CompanySeq
                    ,M.LeaseContSeq
                    ,M.UMDepositTypeSeq
                    ,M.Rate     
                    ,M.Amt      
                    ,M.PayDate  
                    ,@UserSeq
                    ,GETDATE()
                    

          FROM  #minjun_TACLeaseContractDeposit_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #minjun_TACLeaseContractDeposit_
   
RETURN  
 /***************************************************************************************************************/


