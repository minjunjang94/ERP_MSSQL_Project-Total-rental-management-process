IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseContractListQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseContractListQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-임대계약조회_minjun
 작성일 - '2020-03-17
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SACLeaseContractListQuery
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
    DECLARE @docHandle                 INT
           ,@ContractDateFr            NCHAR(8)
           ,@ContractDateTo            NCHAR(8)
           ,@LeaseDateFr               NCHAR(8)
           ,@LeaseDateTo               NCHAR(8)
           ,@TenantName                NVARCHAR(200)

  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT 
            @ContractDateFr        = RTRIM(LTRIM(ISNULL(ContractDateFr       , '')))
           ,@ContractDateTo        = RTRIM(LTRIM(ISNULL(ContractDateTo       , '')))
           ,@LeaseDateFr           = RTRIM(LTRIM(ISNULL(LeaseDateFr          , '')))
           ,@LeaseDateTo           = RTRIM(LTRIM(ISNULL(LeaseDateTo          , '')))
           ,@TenantName            = RTRIM(LTRIM(ISNULL(TenantName           , '')))
           
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)

      WITH (   
                 docHandle              INT
                ,ContractDateFr         NCHAR(8)
                ,ContractDateTo         NCHAR(8)
                ,LeaseDateFr            NCHAR(8)
                ,LeaseDateTo            NCHAR(8)
                ,TenantName             NVARCHAR(200)
                )


      IF @ContractDateFr = '' SET @ContractDateFr = '19000101'
      IF @ContractDateTo = '' SET @ContractDateTo = '99991231'
      IF @LeaseDateFr = ''    SET @LeaseDateFr = '19000101'
      IF @LeaseDateTo = ''    SET @LeaseDateTo = '99991231'
      
      
          
    -- 최종Select
   SELECT DISTINCT     
              A.LeaseContNo			
             ,G.CustName            AS TenantName			
             ,A.ChargePerson		
             ,A.ChargePersonTel		
             ,A.ChargePersonEmail	
             ,A.UMContractType		
             ,A.ContractDate		
             ,A.LeaseDateFr			
             ,A.LeaseDateTo			
             ,E.LeaseStuffName		
             ,  
             STUFF(
             (
             SELECT ',' + A2.LeaseStuffLocName 
               FROM minjun_TACLeaseContractDetail AS A1 
                    JOIN minjun_TACLeaseStuffLoc  AS A2 ON A1.LeaseStuffSeq  = A2.LeaseStuffSeq 
                                                       AND A1.LeaseStuffSerl = A2.LeaseStuffSerl
              WHERE A1.LeaseStuffSeq  = A2.LeaseStuffSeq 
                AND A1.LeaseStuffSerl = A2.LeaseStuffSerl
                AND A1.LeaseContSeq   = A.LeaseContSeq
              FOR XML PATH('')
              )
              ,1,1,'')  AS LeaseStuffLocName

          --   ,STUFF((
          --     SELECT ',' + C1.LeaseStuffLocName
          --       FROM minjun_TACLeaseContract                  AS A1
          --       LEFT OUTER JOIN minjun_TACLeaseContractDetail AS B1 ON B1.LeaseContSeq   = A1.LeaseContSeq
          --       LEFT OUTER JOIN minjun_TACLeaseStuffLoc       AS C1 ON C1.LeaseStuffSeq  = B1.LeaseStuffSeq
          --                                                          AND C1.LeaseStuffSerl = B1.LeaseStuffSerl
          --      WHERE A1.LeaseContSeq = A.LeaseContSeq
          --     FOR XML PATH('')
          -- ),1,1,'') AS LeaseStuffLocName



             ,SUM(C.Amt)            AS Amt          					
             ,F.MinorName           AS UMPayMonthTypeName	
             ,H1.CostAmt            AS RentAmt				
             ,H2.CostAmt            AS CostAmt				
             ,H3.CostAmt            AS PowerAmt			
             ,A.ParkingCnt          AS Car         					
             ,CASE 
                WHEN  GETDATE()  >  A.LeaseDateTo
                THEN 1  
              ELSE
                0
              END  AS LeaseContFinish
            ,A.LeaseStuffSeq
            ,A.LeaseContSeq
            

	FROM	minjun_TACLeaseContract                     AS A
    LEFT OUTER JOIN     minjun_TACLeaseContractDeposit  AS C        ON A.CompanySeq      = C.CompanySeq
                                                                   AND A.LeaseContSeq    = C.LeaseContSeq
    LEFT OUTER JOIN     minjun_TACLeaseStuffLoc         AS D        ON A.CompanySeq      = D.CompanySeq
                                                                   AND A.LeaseContSeq    = D.LeaseStuffSeq
    LEFT OUTER JOIN     minjun_TACLeaseStuff            AS E        ON A.CompanySeq      = E.CompanySeq
                                                                   AND A.LeaseStuffSeq   = E.LeaseStuffSeq
    LEFT OUTER JOIN    _TDAUMinor                       AS F        ON A.CompanySeq      = F.CompanySeq
                                                                   AND A.UMPayMonthType  = F.MinorSeq
    LEFT OUTER JOIN    _TDACust                         AS G        ON G.CompanySeq      = A.CompanySeq 
                                                                   AND G.CustSeq         = A.TenantSeq    
    LEFT OUTER JOIN    (SELECT CostAmt,CompanySeq,LeaseContSeq      FROM minjun_TACLeaseContractCost    WHERE  UMCostType = 2000424001)     
                                                        AS H1       ON H1.CompanySeq     = A.CompanySeq 
                                                                   AND H1.LeaseContSeq   = A.LeaseContSeq                                                                   
    LEFT OUTER JOIN    (SELECT CostAmt,CompanySeq,LeaseContSeq      FROM minjun_TACLeaseContractCost    WHERE  UMCostType = 2000424002)     
                                                        AS H2       ON H2.CompanySeq     = A.CompanySeq 
                                                                   AND H2.LeaseContSeq   = A.LeaseContSeq  
    LEFT OUTER JOIN    (SELECT CostAmt,CompanySeq,LeaseContSeq      FROM minjun_TACLeaseContractCost    WHERE  UMCostType = 2000424003)     
                                                        AS H3       ON H3.CompanySeq     = A.CompanySeq 
                                                                   AND H3.LeaseContSeq   = A.LeaseContSeq                                                       
                                                                    


    --LEFT OUTER JOIN (SELECT DISTINCT D.LeaseContSeq, D.LeaseStuffSeq,
    --                             STUFF(
    --                             (
    --                             SELECT ',' + A2.LeaseStuffLocName 
    --                               FROM minjun_TACLeaseContractDetail AS A1 
    --                                    JOIN minjun_TACLeaseStuffLoc  AS A2 ON A1.LeaseStuffSeq  = A2.LeaseStuffSeq 
    --                                                                       AND A1.LeaseStuffSerl = A2.LeaseStuffSerl
    --                              WHERE A1.LeaseStuffSeq  = A2.LeaseStuffSeq 
    --                                AND A1.LeaseStuffSerl = A2.LeaseStuffSerl
    --                                AND A1.LeaseContSeq   = D.LeaseContSeq
    --                              FOR XML PATH('')
    --                              )
    --                              ,1,1,'') AS LocGather
    --                              FROM minjun_TACLeaseContractDetail AS D
    --                              )                                  AS Z      ON Z.LeaseContSeq  = A.LeaseContSeq 
    --                                                                          AND Z.LeaseStuffSeq = A.LeaseStuffSeq
    --                                                         
                                                             
                                                                                                                                                             


	WHERE  A.CompanySeq = @CompanySeq
       AND A.ContractDate   BETWEEN @ContractDateFr And @ContractDateTo
       AND A.LeaseDateFr    BETWEEN @LeaseDateFr    And @LeaseDateTo
       AND (@TenantName       =''         OR   G.CustName            LIKE @TenantName    + '%'  ) 
    GROUP BY 
     A.LeaseContNO
    ,G.CustName
    ,A.ChargePerson
    ,A.ChargePersonTel		
    ,A.ChargePersonEmail	
    ,A.UMContractType		
    ,A.ContractDate		
    ,A.LeaseDateFr			
    ,A.LeaseDateTo			
    ,E.LeaseStuffName	
    ,A.LeaseContSeq
    ,F.MinorName  
    ,H1.CostAmt   
    ,H2.CostAmt   
    ,H3.CostAmt   
    ,A.ParkingCnt 
    ,A.LeaseStuffSeq
    ,A.LeaseContSeq


RETURN


select * from Edu10_THRBook_jun