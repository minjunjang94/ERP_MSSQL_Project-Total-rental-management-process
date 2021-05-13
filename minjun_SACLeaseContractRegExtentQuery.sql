IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegExtentQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegExtentQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약등록_minjun : 면적조회
 작성일 - '2020-04-22
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegExtentQuery
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
           ,@LeaseContSeq        INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT @LeaseContSeq          = RTRIM(LTRIM(ISNULL(LeaseContSeq          , 0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH ( LeaseContSeq        INT)
    
    -- 최종Select
    SELECT	 
            
             B.LeaseStuffLocName                                            --임대위치	
            ,B.PrivateExtentM                                               --전용면적(m2)
            ,B.SharingExtentM                                               --공유면적(m2)	
            ,B.PrivateExtentP                                               --전용면적(평)
            ,B.SharingExtentP                                               --공유면적(평)	
            ,(B.PrivateExtentM + B.SharingExtentM)   AS   Total_M2
            ,(B.PrivateExtentP + B.SharingExtentP)   AS   Total_
            ,B.Remark                                                       --비고		
            ,A.LeaseContSerl                                                --순번		
            ,A.LeaseContSeq  
            ,A.LeaseStuffSeq
            ,B.LeaseStuffSerl

				
    FROM    minjun_TACLeaseContractDetail               AS  A   WITH(NOLOCK)
    LEFT OUTER JOIN minjun_TACLeaseStuffLoc             AS  B                   ON B.CompanySeq     =   A.CompanySeq
                                                                               AND B.LeaseStuffSeq  =   A.LeaseStuffSeq
                                                                               AND B.LeaseStuffSerl =   A.LeaseStuffSerl

    WHERE   A.CompanySeq       = @CompanySeq
      AND   A.LeaseContSeq     = @LeaseContSeq
      
RETURN
