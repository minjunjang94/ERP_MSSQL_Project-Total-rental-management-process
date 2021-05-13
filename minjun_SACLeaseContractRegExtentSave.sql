IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegExtentSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegExtentSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ�����_minjun : ��������
 �ۼ��� - '2020-04-22
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegExtentSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS
    DECLARE @TblName                NVARCHAR(MAX)   -- Table��
           ,@SeqName                NVARCHAR(MAX)   -- Seq��
           ,@LeaseContSerlName      NVARCHAR(MAX)   -- LeaseContSerl��
           ,@TblColumns             NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName                  = N'minjun_TACLeaseContractDetail'
           ,@SeqName                  = N'LeaseContSeq'
           ,@LeaseContSerlName        = N'LeaseContSerl'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #minjun_TACLeaseContractDetail_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#minjun_TACLeaseContractDetail_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		        -- ���̺��      
                  '#minjun_TACLeaseContractDetail_',		        -- �ӽ� ���̺��      
                  'LeaseContSeq, LeaseContSerl',              -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,               -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractDetail_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        DELETE  A
          FROM  #minjun_TACLeaseContractDetail_                          AS M
                JOIN minjun_TACLeaseContractDetail            AS A  WITH(NOLOCK)    ON   A.CompanySeq         = @CompanySeq
                                                                                    AND  A.LeaseContSeq      = M.LeaseContSeq
                                                                                    AND  A.LeaseContSerl     = M.LeaseContSerl
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractDetail_ WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_TACLeaseContractDetail 
           SET  
                 LeaseStuffSeq      = M.LeaseStuffSeq
                ,LeaseStuffSerl     = M.LeaseStuffSerl
                ,Remark             = M.Remark         
                ,LastUserSeq        = @UserSeq
                ,LastDateTime       = GETDATE()
                
          FROM  #minjun_TACLeaseContractDetail_                          AS M
                JOIN minjun_TACLeaseContractDetail                       AS A  WITH(NOLOCK)  ON   A.CompanySeq        = @CompanySeq
                                                                                            AND  A.LeaseContSeq       = M.LeaseContSeq
                                                                                            AND  A.LeaseContSerl      = M.LeaseContSerl
         WHERE  M.WorkingTag    = 'U'                                                                               
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseContractDetail_ WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_TACLeaseContractDetail (
                     CompanySeq
                    ,LeaseContSeq
                    ,LeaseContSerl
                    ,LeaseStuffSerl
                    ,LeaseStuffSeq  
                    ,Remark         
                    ,LastUserSeq    
                    ,LastDateTime   
                  
            )
            SELECT   @CompanySeq
                    ,M.LeaseContSeq
                    ,M.LeaseStuffSerl
                    ,M.LeaseContSerl
                    ,M.LeaseStuffSeq
                    ,M.Remark         
                    ,@UserSeq
                    ,GETDATE()


          FROM  #minjun_TACLeaseContractDetail_          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #minjun_TACLeaseContractDetail_
   
RETURN  
 /***************************************************************************************************************/


