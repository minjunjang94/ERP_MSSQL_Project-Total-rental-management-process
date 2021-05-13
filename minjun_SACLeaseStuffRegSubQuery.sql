IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseStuffRegSubQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseStuffRegSubQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대물건등록_minjun : 서브조회
 작성일 - '2020-04-21
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseStuffRegSubQuery
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
           ,@LeaseStuffSeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT @LeaseStuffSeq         = RTRIM(LTRIM(ISNULL(LeaseStuffSeq          , 0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (LeaseStuffSeq        INT)
    
    -- 최종Select
    SELECT	 
            
             A.LeaseStuffLocName                                            --임대위치	
            ,A.PrivateExtentM                                               --전용면적(m2)
            ,A.SharingExtentM                                               --공유면적(m2)	
            ,A.PrivateExtentP                                               --전용면적(평)
            ,A.SharingExtentP                                               --공유면적(평)	
            ,(A.PrivateExtentM + A.SharingExtentM)   AS   Total_M2
            ,(A.PrivateExtentP + A.SharingExtentP)   AS   Total_
            ,A.Remark                                                       --비고		
            ,A.LeaseStuffSerl                                               --순번		

								
    FROM    minjun_TACLeaseStuffLoc               AS  A   WITH(NOLOCK)

    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseStuffSeq    = @LeaseStuffSeq
      
RETURN

SELECT * FROM  minjun_TACLeaseStuff
SELECT * FROM  minjun_TACLeaseStuffLoc