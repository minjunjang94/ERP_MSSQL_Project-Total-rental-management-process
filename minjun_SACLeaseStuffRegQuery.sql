IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대물건등록_minjun : 조회
 작성일 - '2020-04-21
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml데이터
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- 회사 번호
   ,@LanguageSeq    INT             = 1     -- 언어 번호
   ,@UserSeq        INT             = 0     -- 사용자 번호
   ,@PgmSeq         INT             = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@LeaseStuffSeq  INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @LeaseStuffSeq       = ISNULL(LeaseStuffSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (LeaseStuffSeq        INT) --필드 명과 데이터 타입을 적어줘야 한다.
    
    -- 최종Select
    SELECT   A.LeaseStuffName
            ,A.Area
            ,A.LeaseStuffSeq


     FROM	minjun_TACLeaseStuff		    AS A	WITH(NOLOCK)

     WHERE  A.CompanySeq          = @CompanySeq
  
RETURN