IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseElecChargeRegQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseElecChargeRegQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대전기료등록_minjun : 조회
 작성일 - '2020-04-28
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROCEDURE dbo.minjun_SACLeaseElecChargeRegQuery
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
    DECLARE  @docHandle      INT
            ,@TenantSeq      INT
            ,@AccYM          NCHAR(6)


    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      


    -- 조회조건 받아오기
    SELECT         
             @TenantSeq     = RTRIM(LTRIM(ISNULL(TenantSeq    ,   0)))
            ,@AccYM         = RTRIM(LTRIM(ISNULL(AccYM        ,  '')))



    FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
    WITH  ( 
            TenantSeq          INT 
           ,AccYM              NCHAR(6)           
           )

    
    -- 조회결과 담아주기
    SELECT                                           
             T.CustName                AS  TenantName            --임차인         
            ,B1.TenantSeq                                        --임차인코드
            ,A.AccYM                   AS  ThisYYMM              --대상년월
            ,A.AccYMFr
            ,A.AccYMTo
            ,B2.LeaseStuffLocName                                --임대위치
            ,(B2.PrivateExtentM + B2.SharingExtentM)            AS  RentArea                                                                --임대면적
            ,A.BfrElecMeter                                      --전월계랑기지침
            ,A.ThisElecMeter                                     --당월계량기지침
            ,(A.ThisElecMeter - A.BfrElecMeter)     AS  UseAmt   --사용량
            ,A.UnitCost                                          --KW당단가
            ,A.ElecCharge                                        --전기료
            ,D.LeaseContSeq
            ,D.LeaseContSerl
           

            

      FROM minjun_TACLeaseContract                        AS B1     
      LEFT OUTER JOIN minjun_TACLeaseContractDetail       AS D      ON D.CompanySeq        = B1.CompanySeq   
                                                                   AND D.LeaseContSeq      = B1.LeaseContSeq 
      LEFT OUTER JOIN minjun_TACLeaseElecCharge           AS A      ON A.CompanySeq        = D.CompanySeq   
                                                                   AND A.LeaseContSeq      = D.LeaseContSeq 
                                                                   AND A.LeaseContSerl     = D.LeaseContSerl
      LEFT OUTER JOIN minjun_TACLeaseStuffLoc             AS B2     ON B2.CompanySeq       = D.CompanySeq
                                                                   AND B2.LeaseStuffSeq    = D.LeaseStuffSeq
                                                                   AND B2.LeaseStuffSerl   = D.LeaseStuffSerl
      LEFT OUTER JOIN _TDACust                            AS T      ON T.CompanySeq        = B1.CompanySeq
                                                                   AND T.CustSeq           = B1.TenantSeq      



     WHERE  A.CompanySeq    = @CompanySeq
       AND (@TenantSeq                     = 0                    OR  T.CustSeq                  =              @TenantSeq                      )
       AND (@AccYM                         = ''                   OR  A.AccYM                    LIKE           @AccYM              + '%'       )   
 


RETURN