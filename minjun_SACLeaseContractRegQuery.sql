IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractRegQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractRegQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약등록_minjun : 조회
 작성일 - '2020-04-22
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractRegQuery
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
           ,@LeaseContSeq   INT
  

    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT   @LeaseContSeq       = ISNULL(LeaseContSeq       ,  0)
             


      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH  (LeaseContSeq        INT --필드 명과 데이터 타입을 적어줘야 한다.
            )
    


    -- 최종Select
    SELECT   

             A.LeaseContNo
            ,A.ContractDate
            ,A.LeaseContSeq
            ,B.Area
            ,B.LeaseStuffName
            ,C.CustName           AS TenantName
            ,A.ChargePerson
            ,A.ChargePersonTel
            ,A.ChargePersonEmail
            ,C.BizNo
            ,C.Owner
            ,C.BizAddr            AS Address
            ,A.UMContractType 
            ,A.UMPayMonthType     
            ,E.MinorName            AS  UMPayMonthTypeName
            ,A.LeaseDateFr
            ,A.LeaseDateTo
            ,A.ParkingCnt
            ,A.ManageEmp
            ,A.Purpose
            ,A.SpecialNote
            ,A.LeaseContName
            ,D.LeaseStuffSeq
            ,D.TenantSeq
			,A.FileSeq


     FROM	            minjun_TACLeaseContract		            AS A	        WITH(NOLOCK)
     LEFT OUTER JOIN    minjun_TACLeaseStuff                    AS B            ON  B.CompanySeq        = A.CompanySeq
                                                                               AND  B.LeaseStuffSeq     = A.LeaseStuffSeq        
     LEFT OUTER JOIN    _TDACust                                AS C            ON  C.CompanySeq        = A.CompanySeq 
                                                                               AND  C.CustSeq           = A.TenantSeq
     LEFT OUTER JOIN    minjun_TACLeaseContract                 AS D            ON  D.CompanySeq        = A.CompanySeq 
                                                                               AND  D.LeaseContSeq      = A.LeaseContSeq                             
     LEFT OUTER JOIN    _TDAUMinor                              AS E            ON  E.CompanySeq        = D.CompanySeq
                                                                               AND  E.MinorSeq          = D.UMPayMonthType

     WHERE  A.CompanySeq          = @CompanySeq
       AND  A.LeaseContSeq        = @LeaseContSeq
  
RETURN