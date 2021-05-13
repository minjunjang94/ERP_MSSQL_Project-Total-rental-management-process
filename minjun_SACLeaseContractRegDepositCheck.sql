IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegDepositCheck' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegDepositCheck
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약등록_minjun : 보증금체크
 작성일 - '2020-04-22
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegDepositCheck
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
    SELECT  @TblName    = N'minjun_TACLeaseContractDeposit'
           ,@SeqName    = N'LeaseContSeq'
           ,@SerlName   = N''
           ,@MaxSerl    = 0
    
    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #minjun_TACLeaseContractDeposit_ (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock3', '#minjun_TACLeaseContractDeposit_' 
    
    IF @@ERROR <> 0 RETURN






    --UMDepositType의 중복체크 WHY? minjun_TACLeaseContractDeposit 테이블의 키값이다.
       UPDATE  #minjun_TACLeaseContractDeposit_
          SET  Result          = '보증금구분이 중복되었습니다.'
              ,MessageType     = 9999
              ,Status          = 9999
         FROM  #minjun_TACLeaseContractDeposit_     AS M
         JOIN  minjun_TACLeaseContractDeposit       AS A     WITH(NOLOCK)   ON  A.CompanySeq      = @CompanySeq
                                                                            AND A.LeaseContSeq    = M.LeaseContSeq
         WHERE A.UMDepositType = M.UMDepositType
    


                        
    UPDATE  #minjun_TACLeaseContractDeposit_
       SET  Result          = '보증금구분이 중복되었습니다.'
           ,MessageType     = 9999
           ,Status          = 9999
      FROM  #minjun_TACLeaseContractDeposit_     AS M
            JOIN(   SELECT  X.UMDepositType
                      FROM  minjun_TACLeaseContractDeposit         AS X   WITH(NOLOCK)
                     WHERE  X.CompanySeq    = @CompanySeq
                       AND  NOT EXISTS( SELECT  1
                                          FROM  #minjun_TACLeaseContractDeposit_
                                         WHERE  WorkingTag IN('U', 'D')
                                           AND  Status = 0
                                           AND  LeaseContSeq     = X.LeaseContSeq
                                           )

                    INTERSECT  --기존에 있던 값을 가지고 있기 위해 기존에 있는 임시테이블에 던져줌
                    SELECT  Y.UMDepositType
                      FROM  #minjun_TACLeaseContractDeposit_         AS Y   WITH(NOLOCK)
                     WHERE  Y.WorkingTag IN('A', 'U')
                       AND  Y.Status = 0

                 )AS A    ON  A.UMDepositType  = M.UMDepositType
     WHERE  M.WorkingTag IN('A', 'U')
       AND  M.Status = 0




   -- -- 채번해야 하는 데이터 수 확인
   -- SELECT @Count = COUNT(1) FROM #minjun_TACLeaseContractDeposit_ WHERE WorkingTag = 'A' AND Status = 0 
   --  
   -- -- 채번
   -- IF @Count > 0
   -- BEGIN
   --     -- Serl Max값 가져오기
   --     SELECT  @MaxSerl    = MAX(ISNULL(A.LeaseContSerl, 0))
   --       FROM  #minjun_TACLeaseContractDeposit_                              AS M
   --             LEFT OUTER JOIN minjun_TACLeaseContractDeposit                AS A  WITH(NOLOCK)  ON  A.CompanySeq          = @CompanySeq
   --                                                                                              AND  A.LeaseContSeq        = M.LeaseContSeq
   --      WHERE  M.WorkingTag IN('A')
   --        AND  M.Status = 0                    
   --     
   --     UPDATE  #minjun_TACLeaseContractDeposit_
   --        SET  UMDepositType = @MaxSerl + DataSeq
   --      WHERE  WorkingTag  = 'A'
   --        AND  Status      = 0
   -- END
   -- 
    SELECT * FROM #minjun_TACLeaseContractDeposit_
    
RETURN