IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ����
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegSave
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
           ,@ItemTblName    NVARCHAR(MAX)   -- ��Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_TACLeaseContract'
           ,@ItemTblName    = N'minjun_TACLeaseContractDetail'
           ,@SeqName        = N'LeaseContSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContract_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#minjun_TACLeaseContract_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,	-- ���̺��      
                  '#minjun_TACLeaseContract_',  -- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContract_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,	  -- ���̺��      
                            '#minjun_TACLeaseContract_',  -- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseContract_                       AS M
                JOIN minjun_TACLeaseContractDetail              AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                   AND  A.LeaseContSeq  = M.LeaseContSeq


         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN





        --*********************************************************************
        SET @ItemTblName = 'minjun_TACLeaseContractDeposit'
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,	  -- ���̺��      
                            '#minjun_TACLeaseContract_',  -- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseContract_                       AS M
                JOIN minjun_TACLeaseContractDeposit              AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                    AND  A.LeaseContSeq  = M.LeaseContSeq


         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN





        --*********************************************************************
        SET @ItemTblName = 'minjun_TACLeaseContractCost'
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,	  -- ���̺��      
                            '#minjun_TACLeaseContract_',  -- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN


        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseContract_                       AS M
                JOIN minjun_TACLeaseContractCost                AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                   AND  A.LeaseContSeq  = M.LeaseContSeq


         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN





        








        -- Master���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseContract_                      AS M
                JOIN minjun_TACLeaseContract                   AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                  AND  A.LeaseContSeq = M.LeaseContSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END




    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContract_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET        
                   LeaseContName          = M.LeaseContName     
                  ,LeaseContNo            = M.LeaseContNo       
                  ,ContractDate           = M.ContractDate      
                  ,LeaseContSeq           = M.LeaseContSeq  
                  ,LeaseStuffSeq          = M.LeaseStuffSeq   
                  ,TenantSeq              = M.TenantSeq     
                  ,ChargePerson           = M.ChargePerson      
                  ,ChargePersonTel        = M.ChargePersonTel   
                  ,ChargePersonEmail      = M.ChargePersonEmail 
                  ,UMContractType         = M.UMContractType    
                  ,UMPayMonthType         = M.UMPayMonthType
                  ,LeaseDateFr            = M.LeaseDateFr       
                  ,LeaseDateTo            = M.LeaseDateTo       
                  ,ParkingCnt             = M.ParkingCnt        
                  ,ManageEmp              = M.ManageEmp         
                  ,Purpose                = M.Purpose           
                  ,SpecialNote            = M.SpecialNote       
                  ,FileSeq                = M.FileSeq           
                  ,LastUserSeq            = @UserSeq
                  ,LastDateTime           = GETDATE()


          FROM  #minjun_TACLeaseContract_                         AS M
                JOIN minjun_TACLeaseContract                      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                     AND  A.LeaseContSeq = M.LeaseContSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContract_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO 
        minjun_TACLeaseContract (
                CompanySeq
               ,LeaseContSeq
               ,LeaseStuffSeq
               ,LeaseContName      
               ,LeaseContNo        
               ,ContractDate        
               ,TenantSeq          
               ,ChargePerson       
               ,ChargePersonTel    
               ,ChargePersonEmail  
               ,UMContractType     
               ,UMPayMonthType     
               ,LeaseDateFr        
               ,LeaseDateTo        
               ,ParkingCnt         
               ,ManageEmp          
               ,Purpose            
               ,SpecialNote        
               ,FileSeq            
               ,LastUserSeq        
               ,LastDateTime       
        )
        SELECT  
             @CompanySeq
            ,M.LeaseContSeq
            ,M.LeaseStuffSeq
            ,M.LeaseContName     
            ,M.LeaseContNo       
            ,M.ContractDate        
            ,M.TenantSeq         
            ,M.ChargePerson      
            ,M.ChargePersonTel   
            ,M.ChargePersonEmail 
            ,M.UMContractType    
            ,M.UMPayMonthType
            ,M.LeaseDateFr       
            ,M.LeaseDateTo       
            ,M.ParkingCnt        
            ,M.ManageEmp         
            ,M.Purpose           
            ,M.SpecialNote       
            ,M.FileSeq           
            ,@UserSeq
            ,GETDATE()


          FROM  #minjun_TACLeaseContract_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #minjun_TACLeaseContract_
   
RETURN