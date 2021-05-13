IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseElecChargeRegSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseElecChargeRegSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ��������_minjun_����
 �ۼ��� - '2020-04-28
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseElecChargeRegSave
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
    SELECT  @TblName        = N'minjun_TACLeaseElecCharge'
           ,@ItemTblName    = N'minjun_TACLeaseElecCharge'
           ,@SeqName        = N'LeaseContSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseElecCharge_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#minjun_TACLeaseElecCharge_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,	-- ���̺��      
                  '#minjun_TACLeaseElecCharge_',  -- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
  
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseElecCharge_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,	  -- ���̺��      
                            '#minjun_TACLeaseElecCharge_',  -- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

       -- -- Detail���̺� ������ ����
       -- DELETE  A
       --   FROM  #minjun_TACLeaseElecCharge_                       AS M
       --         JOIN minjun_TACLeaseElecCharge                    AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
       --                                                                              AND  A.LeaseContSeq  = M.LeaseContSeq
       --                                                                             
       --                                                                             
       --
       --  WHERE  M.WorkingTag    = 'D'
       --    AND  M.Status        = 0
       --
       -- IF @@ERROR <> 0 RETURN


        -- Master���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseElecCharge_                      AS M
                JOIN minjun_TACLeaseElecCharge                   AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                    AND  A.LeaseContSeq = M.LeaseContSeq
                                                                                    AND  A.AccYM         = M.AccYM        
                                                                                    AND  A.LeaseContSerl = M.LeaseContSerl
                                                                                    
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0
       
        IF @@ERROR <> 0 RETURN
    END




    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseElecCharge_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET        
                   BfrElecMeter         = M.BfrElecMeter     
                  ,ThisElecMeter        = M.ThisElecMeter    
                  ,UnitCost             = M.UnitCost         
                  ,ElecCharge           = M.ElecCharge     
                  ,LastUserSeq          = @UserSeq
                  ,LastDateTime         = GETDATE()
                  ,AccYMFr              = M.AccYMFr
                  ,AccYMTo              = M.AccYMTo


          FROM  #minjun_TACLeaseElecCharge_                         AS M
                JOIN minjun_TACLeaseElecCharge                      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                       AND  A.LeaseContSeq  = M.LeaseContSeq
                                                                                       AND  A.AccYM         = M.ThisYYMM        
                                                                                       AND  A.LeaseContSerl = M.LeaseContSerl
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseElecCharge_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO 
        minjun_TACLeaseElecCharge (
                CompanySeq   
                ,AccYM  
               ,LeaseContSeq       
               ,LeaseContSerl     
               ,BfrElecMeter  
               ,ThisElecMeter   
               ,UnitCost       
               ,ElecCharge     
               ,LastUserSeq    
               ,LastDateTime 
               ,AccYMFr     
               ,AccYMTo      
        )
        SELECT  
             @CompanySeq  
            ,M.ThisYYMM  
            ,M.LeaseContSeq       
            ,M.LeaseContSerl    
            ,M.BfrElecMeter  
            ,M.ThisElecMeter     
            ,M.UnitCost       
            ,M.ElecCharge     
            ,@UserSeq
            ,GETDATE()   
            ,M.AccYMFr      
            ,M.AccYMTo

          FROM  #minjun_TACLeaseElecCharge_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN

    END
    
    SELECT * FROM #minjun_TACLeaseElecCharge_
   
RETURN