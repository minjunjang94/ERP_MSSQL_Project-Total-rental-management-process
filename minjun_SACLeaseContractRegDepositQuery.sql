IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegDepositQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegDepositQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약등록_minjun : 보증금조회
 작성일 - '2020-04-22
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegDepositQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- 회사 번호
   ,@LanguageSeq    INT            = 1     -- 언어 번호
   ,@UserSeq        INT            = 0     -- 사용자 번호
   ,@PgmSeq         INT            = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle           INT
           ,@LeaseContSeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT @LeaseContSeq         = RTRIM(LTRIM(ISNULL(LeaseContSeq          , 0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock3', @xmlFlags)
      WITH (LeaseContSeq        INT)
    
    -- 최종Select
    SELECT	 
            
             A.LeaseContSeq
            ,A.UMDepositType   AS  UMDepositTypeSeq
            ,A.Rate
            ,A.Amt
            ,A.PayDate


								
    FROM    minjun_TACLeaseContractDeposit               AS  A   WITH(NOLOCK)

    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseContSeq     = @LeaseContSeq
      
RETURN

SELECT * FROM  minjun_TACLeaseStuff
SELECT * FROM  minjun_TACLeaseStuffLoc