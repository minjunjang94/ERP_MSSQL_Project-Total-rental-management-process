IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegDepositSave' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegDepositSave
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약등록_minjun : 보증금저장
 작성일 - '2020-04-22
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegDepositSave
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
    SELECT  @TblName                  = N'minjun_TACLeaseContractDeposit'
           ,@SeqName                  = N'LeaseContSeq'
           ,@LeaseStuffSerlName       = N''

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #minjun_TACLeaseContractDeposit_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#minjun_TACLeaseContractDeposit_' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		        -- 테이블명      
                  '#minjun_TACLeaseContractDeposit_',		        -- 임시 테이블명      
                  'LeaseContSeq,UMDepositType',              -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,               -- 테이블 모든 필드명
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


