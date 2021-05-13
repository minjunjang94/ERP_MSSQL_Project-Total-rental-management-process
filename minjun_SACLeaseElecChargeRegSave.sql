IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseElecChargeRegSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseElecChargeRegSave
GO
    
/*************************************************************************************************    
 설  명 - SP-임대전기료등록_minjun_저장
 작성일 - '2020-04-28
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseElecChargeRegSave
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
           ,@ItemTblName    NVARCHAR(MAX)   -- 상세Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName        = N'minjun_TACLeaseElecCharge'
           ,@ItemTblName    = N'minjun_TACLeaseElecCharge'
           ,@SeqName        = N'LeaseContSeq'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #minjun_TACLeaseElecCharge_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#minjun_TACLeaseElecCharge_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,	-- 테이블명      
                  '#minjun_TACLeaseElecCharge_',  -- 임시 테이블명      
                  @SeqName      ,   -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,   -- 테이블 모든 필드명
                  ''            ,
                  @PgmSeq
  
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #minjun_TACLeaseElecCharge_ WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- 디테일테이블 로그 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- 삭제로그 남기기
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,	  -- 테이블명      
                            '#minjun_TACLeaseElecCharge_',  -- 임시 테이블명      
                            @SeqName      ,   -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                            @TblColumns   ,   -- 테이블 모든 필드명
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

       -- -- Detail테이블 데이터 삭제
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


        -- Master테이블 데이터 삭제
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