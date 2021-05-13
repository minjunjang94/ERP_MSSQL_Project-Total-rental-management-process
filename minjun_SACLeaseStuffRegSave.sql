IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ빰�ǵ��_minjun : ����
 �ۼ��� - '2020-04-21
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegSave
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
    SELECT  @TblName        = N'minjun_TACLeaseStuff'
           ,@ItemTblName    = N'minjun_TACLeaseStuffLoc'
           ,@SeqName        = N'LeaseStuffSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseStuff_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#minjun_TACLeaseStuff_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,	-- ���̺��      
                  '#minjun_TACLeaseStuff_',  -- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseStuff_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,	  -- ���̺��      
                            '#minjun_TACLeaseStuff_',  -- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseStuff_                      AS M
                JOIN minjun_TACLeaseStuffLoc        AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.LeaseStuffSeq = M.LeaseStuffSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
        
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #minjun_TACLeaseStuff_                      AS M
                JOIN minjun_TACLeaseStuff              AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                          AND  A.LeaseStuffSeq = M.LeaseStuffSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseStuff_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET        
                 LeaseStuffName  = M.LeaseStuffName   
                ,Area            = M.Area             
                ,LastUserSeq     = @UserSeq
                ,LastDateTime    = GETDATE()

          FROM  #minjun_TACLeaseStuff_                         AS M
                JOIN minjun_TACLeaseStuff                      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                                  AND  A.LeaseStuffSeq = M.LeaseStuffSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseStuff_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO 
        minjun_TACLeaseStuff (
                CompanySeq
               ,LeaseStuffSeq  
               ,LeaseStuffName 
               ,Area           
               ,LastUserSeq    
               ,LastDateTime   
        )
        SELECT  
             @CompanySeq
            ,M.LeaseStuffSeq
            ,M.LeaseStuffName  
            ,M.Area            
            ,@UserSeq
            ,GETDATE()

          FROM  #minjun_TACLeaseStuff_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #minjun_TACLeaseStuff_
   
RETURN