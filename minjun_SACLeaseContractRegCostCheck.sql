IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegCostCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegCostCheck
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약등록_minjun : 청구체크
 작성일 - '2020-04-23
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegCostCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS    
    DECLARE @MessageType    INT             -- 오류메시지 타입
           ,@Status         INT             -- 상태변수
           ,@Results        NVARCHAR(250)   -- 결과문구
           ,@Count          INT             -- 채번데이터 Row 수
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- 채번 데이터 최대 No
           ,@MaxSerl        INT             -- Serl값 최대값
           ,@TblName        NVARCHAR(MAX)   -- Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@SerlName       NVARCHAR(MAX)   -- Serl명
    
    -- 테이블, 키값 명칭
    SELECT  @TblName    = N'minjun_TACLeaseContractCost'
           ,@SeqName    = N'LeaseContSeq'
           ,@SerlName   = N''
           ,@MaxSerl    = 0
    
    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #minjun_TACLeaseContractCost_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock4', '#minjun_TACLeaseContractCost_' 
    
    IF @@ERROR <> 0 RETURN


    --UMCostType의 중복체크 WHY? minjun_TACLeaseContractCost 테이블의 키값이다.







   -- -- 채번해야 하는 데이터 수 확인
   -- SELECT @Count = COUNT(1) FROM #minjun_TACLeaseContractCost_ WHERE WorkingTag = 'A' AND Status = 0 
   --  
   -- -- 채번
   -- IF @Count > 0
   -- BEGIN
   --     -- Serl Max값 가져오기
   --     SELECT  @MaxSerl    = MAX(ISNULL(A.LeaseContSerl, 0))
   --       FROM  #minjun_TACLeaseContractCost_                              AS M
   --             LEFT OUTER JOIN minjun_TACLeaseContractCost                AS A  WITH(NOLOCK)  ON  A.CompanySeq          = @CompanySeq
   --                                                                                              AND  A.LeaseContSeq        = M.LeaseContSeq
   --      WHERE  M.WorkingTag IN('A')
   --        AND  M.Status = 0                    
   --     
   --     UPDATE  #minjun_TACLeaseContractCost_
   --        SET  UMDepositType = @MaxSerl + DataSeq
   --      WHERE  WorkingTag  = 'A'
   --        AND  Status      = 0
   -- END
   -- 
   SELECT * FROM #minjun_TACLeaseContractCost_
    
RETURN