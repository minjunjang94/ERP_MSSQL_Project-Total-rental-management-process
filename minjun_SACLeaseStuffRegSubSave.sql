IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegSubSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegSubSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ빰�ǵ��_minjun : ��������
 �ۼ��� - '2020-04-21
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegSubSave
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
    SELECT  @TblName                  = N'minjun_TACLeaseStuffLoc'
           ,@SeqName                  = N'LeaseStuffSeq'
           ,@LeaseStuffSerlName       = N'LeaseStuffSerl'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseStuffLoc_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#minjun_TACLeaseStuffLoc_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		        -- ���̺��      
                  '#minjun_TACLeaseStuffLoc_',		        -- �ӽ� ���̺��      
                  'LeaseStuffSeq, LeaseStuffSerl',              -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,               -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseStuffLoc_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        DELETE  A
          FROM  #minjun_TACLeaseStuffLoc_                          AS M
                JOIN minjun_TACLeaseStuffLoc            AS A  WITH(NOLOCK)  ON   A.CompanySeq         = @CompanySeq
                                                                            AND  A.LeaseStuffSeq      = M.LeaseStuffSeq
                                                                            AND  A.LeaseStuffSerl     = M.LeaseStuffSerl
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseStuffLoc_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TACLeaseStuffLoc 
           SET  
                 PrivateExtentM     = M.PrivateExtentM 
                ,SharingExtentM     = M.SharingExtentM 
                --,Total_M2           = M.Total_M2  
                --,Total_             = M.Total_    
                ,LeaseStuffLocName  = M.LeaseStuffLocName    
                ,PrivateExtentP     = M.PrivateExtentP 
                ,SharingExtentP     = M.SharingExtentP  
                ,Remark             = M.Remark         
                ,LastUserSeq        = @UserSeq
                ,LastDateTime       = GETDATE()
                
          FROM  #minjun_TACLeaseStuffLoc_                          AS M
                JOIN minjun_TACLeaseStuffLoc                       AS A  WITH(NOLOCK)  ON   A.CompanySeq        = @CompanySeq
                                                                                       AND  A.LeaseStuffSeq     = M.LeaseStuffSeq
                                                                                       AND  A.LeaseStuffSerl    = M.LeaseStuffSerl
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseStuffLoc_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TACLeaseStuffLoc (
                     CompanySeq
                    ,LeaseStuffSeq
                    ,LeaseStuffSerl
                    ,LeaseStuffLocName
                    ,PrivateExtentM
                    ,SharingExtentM  
                    ,PrivateExtentP
                    ,SharingExtentP
                    ,Remark        
                    ,LastUserSeq   
                    ,LastDateTime  

            )
            SELECT   @CompanySeq
                    ,M.LeaseStuffSeq
                    ,M.LeaseStuffSerl
                    ,M.LeaseStuffLocName
                    ,M.PrivateExtentM 
                    ,M.SharingExtentM   
                    ,M.PrivateExtentP 
                    ,M.SharingExtentP   
                    ,M.Remark         
                    ,@UserSeq
                    ,GETDATE()


          FROM  #minjun_TACLeaseStuffLoc_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #minjun_TACLeaseStuffLoc_
   
RETURN  
 /***************************************************************************************************************/


