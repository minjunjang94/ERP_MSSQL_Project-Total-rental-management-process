IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegSubSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegSubSave
GO
    
/*************************************************************************************************    
 설  명 - SP-임대물건등록_minjun : 서브저장
 작성일 - '2020-04-21
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegSubSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@LeaseStuffSerlName       NVARCHAR(MAX)   -- LeaseStuffSerl명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName                  = N'minjun_TACLeaseStuffLoc'
           ,@SeqName                  = N'LeaseStuffSeq'
           ,@LeaseStuffSerlName       = N'LeaseStuffSerl'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #minjun_TACLeaseStuffLoc_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#minjun_TACLeaseStuffLoc_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		        -- 테이블명      
                  '#minjun_TACLeaseStuffLoc_',		        -- 임시 테이블명      
                  'LeaseStuffSeq, LeaseStuffSerl',              -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,               -- 테이블 모든 필드명
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


