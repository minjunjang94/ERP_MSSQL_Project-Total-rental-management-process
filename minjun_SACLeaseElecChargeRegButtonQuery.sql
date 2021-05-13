IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SACLeaseElecChargeRegButtonQuery' AND xtype = 'P')    
    DROP PROC minjun_SACLeaseElecChargeRegButtonQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ӵ��������_minjun : ��ȸ
 �ۼ��� - '2020-04-28
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROCEDURE dbo.minjun_SACLeaseElecChargeRegButtonQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml������
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT             = 1     -- ��� ��ȣ
   ,@UserSeq        INT             = 0     -- ����� ��ȣ
   ,@PgmSeq         INT             = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE  @docHandle      INT
            ,@TenantSeq      INT
            ,@AccYM          NCHAR(6)


    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      


    -- ��ȸ���� �޾ƿ���
    SELECT         
             @TenantSeq     = RTRIM(LTRIM(ISNULL(TenantSeq    ,   0)))
            ,@AccYM         = RTRIM(LTRIM(ISNULL(AccYM        ,  '')))



    FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
    WITH  ( 
            TenantSeq          INT 
           ,AccYM              NCHAR(6)        
           )


 --����ó��

       



       DELETE
       FROM minjun_TACLeaseElecCharge     
       FROM minjun_TACLeaseElecCharge                      AS A      
       WHERE A.CompanySeq        = @CompanySeq
         AND A.AccYM             = @AccYM  


 -- minjun_TACLeaseElecCharge																	
  ----
    
    -- ��ȸ��� ����ֱ�

    SELECT  
             B1.CompanySeq      
            ,T.CustName                                         AS  TenantName                                                              --������         
            ,B1.TenantSeq                                                                                                                   --�������ڵ�
            ,@AccYM                                             AS  ThisYYMM                                                                 --�����

            ,(CASE WHEN B1.LeaseDateFr >= CONVERT(NCHAR(8), @AccYM + '01', 112)
                     THEN CONVERT(NCHAR(8), B1.LeaseDateFr, 112)
                     ELSE CONVERT(NCHAR(8), @AccYM + '01', 112)
                END 
               ) AS AccYMFr -- ������
              ,(
                   CASE WHEN B1.LeaseDateTo < DATEADD(DAY, -1, DATEADD(MONTH, 1, CONVERT(NCHAR(8), @AccYM + '01', 112))) 
                        THEN CONVERT(NCHAR(8), B1.LeaseDateTo, 112) -- �������(����)           
                        ELSE CONVERT(NCHAR(8), DATEADD(DAY, -1, DATEADD(MONTH, 1, CONVERT(NCHAR(8), @AccYM + '01', 112))), 112)
                   END
               ) AS AccYMTo -- ������
           ,
           
           case
               when ((@AccYM - 1) =  A.AccYM) then A.BfrElecMeter
               when (@AccYM =  A.AccYM)       then A1.BfrElecMeter
           end as BfrElecMeter


            ,B2.LeaseStuffLocName                                                                                                           --�Ӵ���ġ
            ,(B2.PrivateExtentM + B2.SharingExtentM)            AS  RentArea                                                                --�Ӵ����
            ,D.LeaseContSeq
            ,D.LeaseContSerl
            ,B1.LeaseDateFr
            ,B1.LeaseDateTo

     INTO #TEMP1
      FROM minjun_TACLeaseContract                        AS B1     
      LEFT OUTER JOIN minjun_TACLeaseContractDetail       AS D      ON D.CompanySeq        = B1.CompanySeq   
                                                                   AND D.LeaseContSeq      = B1.LeaseContSeq 

      LEFT OUTER JOIN minjun_TACLeaseElecCharge           AS A      ON A.CompanySeq        = D.CompanySeq   
                                                                   AND A.LeaseContSeq      = D.LeaseContSeq 
                                                                   AND A.LeaseContSerl     = D.LeaseContSerl

      LEFT OUTER JOIN minjun_TACLeaseElecCharge           AS A1     ON A1.CompanySeq       = D.CompanySeq   
                                                                   AND A1.LeaseContSeq     = D.LeaseContSeq 
                                                                   AND A1.LeaseContSerl    = D.LeaseContSerl
                                                                   AND LEFT(A1.AccYM, 6)    = @AccYM - 1

      LEFT OUTER JOIN minjun_TACLeaseStuffLoc             AS B2     ON B2.CompanySeq       = D.CompanySeq
                                                                   AND B2.LeaseStuffSeq    = D.LeaseStuffSeq
                                                                   AND B2.LeaseStuffSerl   = D.LeaseStuffSerl
      LEFT OUTER JOIN _TDACust                            AS T      ON T.CompanySeq        = B1.CompanySeq
                                                                   AND T.CustSeq           = B1.TenantSeq   





    SELECT   B1.CompanySeq                                                
            ,B1.LeaseContSeq   
            ,A.LeaseContSerl                    
            ,C.IsCharge  
            ,C.UMCostType

            
     INTO #TEMP2
      FROM minjun_TACLeaseContract                        AS B1     
      LEFT OUTER JOIN minjun_TACLeaseContractDetail       AS A      ON A.CompanySeq        = B1.CompanySeq   
                                                                   AND A.LeaseContSeq      = B1.LeaseContSeq 
      LEFT OUTER JOIN minjun_TACLeaseContractCost         AS C      ON C.CompanySeq        = B1.CompanySeq
                                                                   AND C.LeaseContSeq      = B1.LeaseContSeq
        
     WHERE C.UMCostType = 2000424003
     GROUP BY C.IsCharge, A.LeaseContSerl ,B1.LeaseContSeq, B1.CompanySeq ,C.UMCostType
     ORDER BY B1.LeaseContSeq







     SELECT                                              
             A.TenantName                            --������         
            ,A.TenantSeq                             --�������ڵ�
            ,A.ThisYYMM
            ,A.AccYMFr                               -- ������
            ,A.AccYMTo
            ,A.BfrElecMeter
            ,A.LeaseStuffLocName                     --�Ӵ���ġ
            ,A.RentArea                              --�Ӵ����
            ,A.LeaseContSeq
            ,A.LeaseContSerl
            ,B.IsCharge

    FROM #TEMP1                                         AS  A
    LEFT OUTER JOIN #TEMP2                              AS  B     ON B.CompanySeq     = A.CompanySeq
                                                                 AND B.LeaseContSeq   = A.LeaseContSeq
                                                                 AND B.LeaseContSerl  = A.LeaseContSerl
    WHERE  B.CompanySeq    = @CompanySeq
      AND (@TenantSeq                     = 0                    OR  A.TenantSeq                  =            @TenantSeq                        )
                 AND (    
                       A.LeaseDateFr LIKE @AccYM + '%'
                    OR A.LeaseDateTo LIKE @AccYM + '%'
                    OR @AccYM BETWEEN A.LeaseDateFr AND A.LeaseDateTo
               )              
      AND B.IsCharge = 1





RETURN


