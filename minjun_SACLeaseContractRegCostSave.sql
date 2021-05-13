IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegCostSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegCostSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : û������
 �ۼ��� - '2020-04-23
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegCostSave
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
    SELECT  @TblName                  = N'minjun_TACLeaseContractCost'
           ,@SeqName                  = N'LeaseContSeq'
           ,@LeaseStuffSerlName       = N''

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContractCost_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock4', '#minjun_TACLeaseContractCost_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		                -- ���̺��      
                  '#minjun_TACLeaseContractCost_',	    -- �ӽ� ���̺��      
                  'LeaseContSeq,UMCostType',            -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,                       -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractCost_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        DELETE  A
          FROM  #minjun_TACLeaseContractCost_                          AS M
                JOIN minjun_TACLeaseContractCost            AS A  WITH(NOLOCK)  ON   A.CompanySeq         = @CompanySeq
                                                                               AND   A.LeaseContSeq       = M.LeaseContSeq
                                                                               AND   A.UMCostType         = M.UMCostTypeSeq
          WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractCost_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TACLeaseContractCost 
           SET  
                 CostAmt            = M.CostAmt     
                ,IsCharge           = M.IsCharge    
                ,ItemSeq            = M.ItemSeq    
                ,LastUserSeq        = @UserSeq
                ,LastDateTime       = GETDATE()

               
          FROM  #minjun_TACLeaseContractCost_                          AS M
                JOIN minjun_TACLeaseContractCost                       AS A  WITH(NOLOCK)  ON   A.CompanySeq        = @CompanySeq
                                                                                          AND   A.LeaseContSeq      = M.LeaseContSeq
                                                                                          AND   A.UMCostType        = M.UMCostTypeSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractCost_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TACLeaseContractCost (
                     CompanySeq
                    ,LeaseContSeq
                    ,UMCostType
                    ,CostAmt      
                    ,IsCharge     
                    ,ItemSeq     
                    ,LastUserSeq  
                    ,LastDateTime 
                    
                    
                    

            )
            SELECT   @CompanySeq
                    ,M.LeaseContSeq
                    ,M.UMCostTypeSeq
                    ,M.CostAmt     
                    ,M.IsCharge    
                    ,M.ItemSeq    
                    ,@UserSeq
                    ,GETDATE()
                    

          FROM  #minjun_TACLeaseContractCost_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #minjun_TACLeaseContractCost_
   
RETURN  
 /***************************************************************************************************************/


